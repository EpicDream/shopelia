class Api::V1::EventsController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  before_filter :retrieve_developer_key, :only => :index
  before_filter :prepare_params
  before_filter :set_visitor_cookie
  before_filter :set_developer_cookie

  api :GET, "/api/events", "Create events"
  param :urls, String, "Urls of the products separated by ||", :required => true
  param :tracker, String, "Tracker", :required => false
  param :visitor, String, "Visitor UUID", :required => false
  param :developer, String, "Developer key", :required => true
  def index
    Event.from_urls(
      :urls => params[:urls].split("||"),
      :developer_id => @developer.id,
      :action => @action,
      :tracker => @tracker,
      :visitor => @visitor,
      :ip_address => request.remote_ip,
      :user_agent => request.env['HTTP_USER_AGENT'])
    head :no_content
  end
  
  api :POST, "/api/events", "Create events"
  param :urls, Array, "Urls of the products", :required => true
  param :tracker, String, "Tracker", :required => false
  param :visitor, String, "Visitor UUID", :required => false
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
  
  def retrieve_developer_key
    @developer = Developer.find_by_api_key!(params[:developer])
  end
  
  def prepare_params
    @tracker = params[:tracker]
    @action = params[:type].eql?("click") ? Event::CLICK : Event::VIEW
  end
    
  def set_visitor_cookie 
    if params[:visitor]
      @visitor = params[:visitor]
    else
      @visitor = cookies[:visitor]
      if @visitor.nil?
        @visitor = SecureRandom.hex(16)
        cookies[:visitor] = { :value => @visitor, :expires => 10.years.from_now }
      end
    end
  end
  
  def set_developer_cookie
    cookies[:developer_key] = { :value => @developer.api_key, :expires => 10.years.from_now }
  end
  
end
