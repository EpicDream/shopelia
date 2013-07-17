class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_navbar
  before_filter :set_navigator_properties
  layout :set_layout
  
  def after_sign_in_path_for(resource)
    home_index_path
  end

  def after_sign_out_path_for(resource)
    home_index_path
  end  

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, with: lambda { |exception| render_error 500, exception }
  end

  rescue_from ActionController::RoutingError, ActionController::UnknownController, ::AbstractController::ActionNotFound, ActiveRecord::RecordNotFound, with: lambda { |exception| render_error 404, exception }

  private

  def render_error(status, exception)
    respond_to do |format|
      format.html { render template: "errors/error_#{status}", layout: 'layouts/application', status: status }
      format.all { render nothing: true, status: status }
    end
  end
  
  def set_navbar
    @navbar = {}
    @navbar['home'] = 'active'
  end
  
  def set_locale
    available = %w{fr en}
    I18n.locale = http_accept_language.compatible_language_from(available)
  end
  
  def set_layout
    if params[:no_layout].present?
      false
    else
      'application'
    end
  end
  
  def set_navigator_properties
    ENV['HTTP_USER_AGENT'] = request.env['HTTP_USER_AGENT']
  end
  
end
