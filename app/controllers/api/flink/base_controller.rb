class Api::Flink::BaseController < Api::ApiController
  PAGINATION_DEFAULT_PAGE = 1
  PAGINATION_DEFAULT_PER_PAGE = 10
  
  skip_before_filter :authenticate_user!
  before_filter :authenticate_flinker!
  before_filter :set_locale
  before_filter :set_navigator_properties
  before_filter :retrieve_device
  
  rescue_from Exception do |e|
    Rails.logger.error(e.backtrace.join("\n"))
    render server_error("Global Error")
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
  
  def unauthorized error=I18n.t('devise.failure.invalid')
    { json: { error:error }, status: :unauthorized }
  end
  
  def server_error error=nil
    { json: { error:error }, status: 500 }
  end
  
  def pagination per_page=PAGINATION_DEFAULT_PER_PAGE
    { page:params[:page] || PAGINATION_DEFAULT_PAGE, per_page: params[:per_page] || per_page }
  end
  
  def paged collection, per_page: PAGINATION_DEFAULT_PER_PAGE
    res = collection.paginate(pagination(per_page))
    @has_next = @has_next || res.total_pages > params[:page].to_i
    res
  end
  
  def serialize collection
    ActiveModel::ArraySerializer.new(collection)
  end
  
end
