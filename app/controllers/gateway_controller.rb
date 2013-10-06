class GatewayController < ApplicationController
  before_filter :retrieve_params
  before_filter :retrieve_developer
  before_filter :retrieve_device

  def index
    if @device.present?
      EventsWorker.perform_async({
        :url => @url,
        :developer_id => @developer.id,
        :action => Event::CLICK,
        :tracker => @tracker,
        :device_id => @device.id,
        :ip_address => request.remote_ip
      })
    end
    
    redirect_to "https://www.shopelia.com/checkout?url=#{CGI::escape(@url)}&developer=#{@developer.api_key}"
  end

  private

  def retrieve_params
  	@url = params[:url]
  	@tracker = params[:tracker]
  end

  def retrieve_developer
    @developer = Developer.find_by_api_key!(params[:developer])
  end
    
  def retrieve_device 
    ua = request.env['HTTP_USER_AGENT']
    return if Event.is_bot?(ua)
    if params[:visitor]
      @device = Device.fetch(params[:visitor], ua)
    else
      if cookies[:visitor]
        @device = Device.fetch(cookies[:visitor], ua)
      else
        @device = Device.create(user_agent:ua)
        cookies[:visitor] = { :value => @device.uuid, :expires => 10.years.from_now }
      end
    end
  end
end
