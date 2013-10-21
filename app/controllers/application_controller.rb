class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale
  before_filter :set_navigator_properties
  before_filter :retrieve_developer
  before_filter :retrieve_tracker
  before_filter :retrieve_device
  before_filter :retrieve_remote_ip
  before_filter :retrieve_cart
  layout :set_layout

  def retrieve_cart
    @current_cart = current_cart
  end

  def after_sign_in_path_for(resource)
    home_index_path
  end

  def after_sign_out_path_for(resource)
    home_index_path
  end  

  unless Rails.application.config.consider_all_requests_local
    #rescue_from Exception, with: lambda { |exception| render_error 500, exception }
  end

  rescue_from ActionController::RoutingError, ActionController::UnknownController, ::AbstractController::ActionNotFound, ActiveRecord::RecordNotFound, with: lambda { |exception| render_error 404, exception }

  private

  def current_cart
    @current_cart = current_user ? (current_user.carts.checkout.first || current_user.carts.create) : nil
  end

  def render_error(status, exception)
    respond_to do |format|
      format.html { render template: "errors/error_#{status}", layout: 'layouts/application', status: status }
      format.all { render nothing: true, status: status }
    end
  end
  
  def set_locale
    available = %w{fr en}
    I18n.locale = Rails.env.test? ? "fr" : http_accept_language.compatible_language_from(available)
  end
  
  def set_layout
    if params[:no_layout].present?
      false
    else
      if devise_controller? && resource_name == :developer
        "developers"
      else
        "application"
      end
    end
  end
  
  def set_navigator_properties
    ENV['HTTP_USER_AGENT'] = request.env['HTTP_USER_AGENT']
  end

  def retrieve_remote_ip
    @remote_ip = request.remote_ip
  end
  
  def retrieve_developer
    key = ENV['API_KEY'] || cookies["developer"] || "e35c8cbbcfd7f83e4bb09eddb5a3f4c461c8d30a71dc498a9fdefe217e0fcd44"
    @developer = Developer.find_by_api_key(key)
  end

  def retrieve_tracker
    @tracker = cookies[:tracker]
  end

  def retrieve_device
    if cookies[:visitor]
      @device = Device.fetch(cookies[:visitor], request.env['HTTP_USER_AGENT'])
    else
      @device = Device.create(user_agent:request.env['HTTP_USER_AGENT'])
      cookies[:visitor] = { :value => @device.uuid, :expires => 10.years.from_now, :domain => :all }
    end
  end
end
