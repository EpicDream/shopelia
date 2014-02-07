class Api::Flink::BaseController < Api::ApiController
  skip_before_filter :authenticate_user!
  before_filter :authenticate_flinker!
  before_filter :set_locale
  before_filter :set_navigator_properties
  before_filter :retrieve_device

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
  
end
