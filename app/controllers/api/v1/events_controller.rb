class Api::V1::EventsController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  skip_before_filter :authenticate_developer!
  before_filter :retrieve_developer_key
  before_filter :prepare_params
  before_filter :prepare_urls
  before_filter :set_visitor_cookie
  before_filter :set_developer_cookie
  before_filter :set_tracker_cookie
  before_filter :prepare_jobs

  api :GET, "/api/events", "Create events"
  param :urls, String, "Urls of the products separated by ||", :required => true
  param :tracker, String, "Tracker", :required => false
  param :visitor, String, "Visitor UUID", :required => false
  param :developer, String, "Developer key", :required => true
  def index
    head :no_content
  end
  
  api :POST, "/api/events", "Create events"
  param :urls, Array, "Urls of the products", :required => true
  param :tracker, String, "Tracker", :required => false
  param :visitor, String, "Visitor UUID", :required => false
  def create
    head :no_content
  end
  
  private
  
  def retrieve_developer_key
    @developer = Developer.find_by_api_key!(params[:developer] || request.headers['X-Shopelia-ApiKey'])
  end
  
  def prepare_params
    @tracker = params[:tracker]
    @action = params[:shadow] ? Event::REQUEST :
      params[:type] == 'click' ? Event::CLICK : Event::VIEW
  end

  def prepare_urls
    if params[:urls].is_a?(Array)
      @urls = params[:urls].map{|e| e.unaccent}
    else
      @urls = params[:urls].unaccent.split("||")
    end
  end
  
  def prepare_jobs
    (@urls || []).each do |url|
      EventsWorker.perform_async({
        :url => url.unaccent,
        :developer_id => @developer.id,
        :action => @action,
        :tracker => @tracker,
        :device_id => @device.id,
        :ip_address => request.remote_ip
      })
    end
  end

  def set_visitor_cookie 
    ua = request.env['HTTP_USER_AGENT']
    head :no_content and return if ua =~ /Googlebot/
    if params[:visitor]
      @device = Device.fetch(params[:visitor], ua)
    else
      if cookies[:visitor]
        @device = Device.fetch(cookies[:visitor], ua)
      else
        @device = Device.create(user_agent:ua)
        cookies[:visitor] = { :value => @device.uuid, :expires => 10.years.from_now, :domain => :all }
      end
    end
  end
  
  def set_developer_cookie
    cookies[:developer_key] = { :value => @developer.api_key, :expires => 10.years.from_now, :domain => :all }
  end

  def set_tracker_cookie
    cookies[:tracker] = { :value => @tracker, :expires => 10.years.from_now, :domain => :all }
  end  
end
