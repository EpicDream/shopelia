class ApplicationController < ActionController::Base
  has_mobile_fu
  protect_from_forgery
  before_filter :set_locale
  before_filter :set_navigator_properties
  before_filter :retrieve_developer
  before_filter :retrieve_tracker
  before_filter :retrieve_device
  before_filter :retrieve_remote_ip
  before_filter :retrieve_cart
  layout :set_layout

  rescue_from Exception, :with => :render_error
  rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found
  rescue_from ActionController::RoutingError, :with => :render_not_found

  def retrieve_cart
    @current_cart = current_cart
  end

  def after_sign_in_path_for(resource)
    home_index_path(:from_signin => true)
  end

  def after_sign_out_path_for(resource)
    home_index_path
  end
  
  def raise_not_found!
    raise ActionController::RoutingError.new("No route matches #{params[:unmatched_route]}")
  end

  private

  def render_error(e)
    respond_to do |format| 
      format.html { render template: "errors/error_500", layout: 'layouts/flink', status: 500 }
      format.json { render json:{}, :status => 500 }
      format.all { render nothing: true, status: 500 }
    end
  end

  def render_not_found(e)
    respond_to do |format| 
      format.html { render template: "errors/error_404", layout: 'layouts/flink', status: 404 }
      format.json { render json:{}, :status => 404 }
      format.all { render nothing: true, status: 404 }
    end
  end

  def current_cart
    @current_cart = current_user ? (current_user.carts.checkout.first || current_user.carts.create) : nil
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
