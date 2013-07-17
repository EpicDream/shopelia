class Api::V1::EventsController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  before_filter :prepare_params
  before_filter :set_visitor_cookie
  before_filter :set_developer_cookie

  api :POST, "/api/events", "Create events"
  param :urls, Array, "Urls of the products", :required => true
  param :tracker, String, "Tracker", :required => false
  def create
    Event.from_urls(
      :urls => params[:urls],
      :developer_id => @developer.id,
      :action => @action,
      :tracker => @tracker,
      :visitor => @visitor,
      :ip_address => request.remote_ip,
      :user_agent => request.env['HTTP_USER_AGENT'])
    head :no_content
  end
  
  private
  
  def prepare_params
    @tracker = params[:tracker]
    @action = params[:action].eql?("click") ? Event::CLICK : Event::VIEW
  end
    
  def set_visitor_cookie 
    @visitor = cookies[:visitor]
    if @visitor.nil?
      @visitor = SecureRandom.hex(16)
      cookies[:visitor] = { :value => @visitor, :expires => 10.years.from_now }
    end
  end
  
  def set_developer_cookie
    cookies[:developer_key] = { :value => @developer.api_key, :expires => 10.years.from_now }
  end
  
end
