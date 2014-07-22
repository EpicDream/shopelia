class Api::ApiController < ActionController::Base
  prepend_before_filter :get_auth_token, :authenticate_developer!
  before_filter :authenticate_user!
  before_filter :set_api_locale
  after_filter :remove_session_cookie
  before_filter :set_navigator_properties
  before_filter :retrieve_tracker
  before_filter :retrieve_device
  before_filter :retrieve_country_iso
  before_filter :retrieve_user_language
  before_filter :retrieve_user_timezone
  before_filter :complete_flinker_params
  
  rescue_from ActiveRecord::RecordNotFound do |e|
    render :json => {:error => "Object not found"}, :status => :not_found
  end
  
  private
  
  def set_api_locale
    I18n.locale = "fr"
  end

  def get_auth_token
    params[:auth_token] = request.headers["X-Shopelia-AuthToken"] if params[:auth_token].blank?
  end
  
  def authenticate_developer!
    @developer = Developer.find_by_api_key(ENV['API_KEY'] || request.headers['X-Shopelia-ApiKey'])
    render json: { error:I18n.t('developers.unauthorized') }, status: :unauthorized if @developer.nil?
  rescue
    render json: { error:I18n.t('developers.unauthorized') }, status: :unauthorized
  end

  def remove_session_cookie
    request.session_options[:skip] = true
  end
  
  def set_navigator_properties
    @user_agent = ENV['HTTP_USER_AGENT'] = request.env['HTTP_USER_AGENT']
  end

  def retrieve_tracker
    @tracker = cookies[:tracker] || params[:tracker]
  end

  def retrieve_device
    if @user_agent =~ /^shopelia\:/
      @device = Device.from_user_agent(@user_agent)
    else
      visitor = cookies[:visitor] || params[:visitor]
      @device = Device.find_by_uuid(visitor) unless visitor.blank?
    end
  end
  
  def retrieve_country_iso
    params[:"x-country-iso"] = request.headers["X-Flink-Country-Iso"]
    params[:"x-country-iso"] ||= 'GB'
  end
  
  def retrieve_user_language
    params[:"x-user-language"] = request.headers["X-Flink-User-Language"]
  end
  
  def retrieve_user_timezone
    params[:"x-user-timezone"] = request.headers["X-Flink-User-Timezone"]
  end
  
  def complete_flinker_params
    params[:flinker] ||= {}
    params[:flinker].merge!({ 
      developer_id: @developer.try(:id), 
      country_iso: params[:"x-country-iso"],
      lang_iso: params[:"x-user-language"],
      timezone: params[:"x-user-timezone"],
    })
  end
  
  def device_attributes
    user_agent = request.env['HTTP_USER_AGENT']
    hash = user_agent.gsub(/^flink:/, "").split(/\:/).map{|e| e.match(/^(.*)\[(.*)\]$/)[1..2]}.map{|e| { e[0] => e[1] }}.inject(:merge)
    { os: hash["os"], os_version: hash["os_version"], version: hash["version"], 
      build: hash["build"].to_i, phone: hash["phone"], device_uuid: hash["uuid"], country_iso: params[:"x-country-iso"],
      lang_iso: params[:"x-user-language"], timezone: params[:"x-user-timezone"]
    }
  rescue
    {}
  end
  
end
