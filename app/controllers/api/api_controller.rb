class Api::ApiController < ActionController::Base
  prepend_before_filter :get_auth_token
  before_filter :authenticate_developer!
  before_filter :authenticate_user!
  after_filter :remove_session_cookie
  before_filter :set_navigator_properties
  before_filter :retrieve_tracker

  rescue_from ActiveRecord::RecordNotFound do |e|
    render :json => {:error => "Object not found"}, :status => :not_found
  end
  
  private
  
  def get_auth_token
    params[:auth_token] = request.headers["X-Shopelia-AuthToken"] if params[:auth_token].blank?
  end
  
  def authenticate_developer!
    @developer = Developer.find_by_api_key(ENV['API_KEY'] || request.headers['X-Shopelia-ApiKey'])
    render json: { error:I18n.t('developers.unauthorized') }, status: :unauthorized if @developer.nil?
  end

  def remove_session_cookie
    request.session_options[:skip] = true
  end
  
  def set_navigator_properties
    ENV['HTTP_USER_AGENT'] = request.env['HTTP_USER_AGENT']
  end

  def retrieve_tracker
    @tracker = cookies[:tracker]
  end

end
