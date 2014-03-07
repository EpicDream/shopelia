class Api::Flink::BaseController < Api::ApiController
  PAGINATION_DEFAULT_PAGE = 1
  PAGINATION_DEFAULT_PER_PAGE = 10
  
  skip_before_filter :authenticate_user!
  before_filter :authenticate_flinker!
  before_filter :set_locale
  before_filter :set_navigator_properties
  before_filter :retrieve_device
  
  rescue_from Exception do |e|
    render server_error(e)
  end

  def set_locale
    available = %w{fr en}
    I18n.locale = Rails.env.test? ? "fr" : http_accept_language.compatible_language_from(available)
  end

  def set_navigator_properties
    @user_agent = ENV['HTTP_USER_AGENT'] = request.env['HTTP_USER_AGENT']
  end

  def retrieve_device
    @device = Device.from_flink_user_agent(@user_agent, current_flinker) if @user_agent =~ /^flink\:/ && current_flinker.present?
  end
  
  protected
  
  def unauthorized error=I18n.t('devise.failure.invalid'), exception=nil
    api_log("#unauthorized", exception)
    { json: { error:error }, status: :unauthorized }
  end
  
  def server_error exception=nil
    api_log("#server_error", exception)
    { json: { error:"Server Error" }, status: 500 }
  end
  
  def success
    { json: { status: :ok }}
  end
  
  def pagination per_page=PAGINATION_DEFAULT_PER_PAGE
    { page:params[:page] || PAGINATION_DEFAULT_PAGE, per_page: params[:per_page] || per_page }
  end
  
  def paged collection, per_page: PAGINATION_DEFAULT_PER_PAGE
    res = collection.paginate(pagination(per_page))
    @has_next = @has_next || res.total_pages > params[:page].to_i
    res
  end
  
  def serialize collection, opts={}
    ActiveModel::ArraySerializer.new(collection, opts)
  end
  
  def api_log key, exception=nil
    return unless exception
    Rails.logger.error(%Q{[API #{key}] #{exception.inspect} \n #{exception.backtrace.join("\n")}})
  end
  
  def scope
    { developer:@developer, device:@device, flinker:current_flinker, short:true }
  end
  
  def epochs_to_dates keys
    keys.each { |key|  
      date = params[key] && Time.at(params[key].to_i)
      params[key] = date
    }
  end
  
end
