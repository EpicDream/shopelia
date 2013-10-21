class Api::V1::Products::RequestsController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  before_filter :prepare_urls
  before_filter :prepare_jobs

  api :POST, "/api/products/requests", "Create events for products"
  param :urls, Array, "Urls of the products", :required => true
  def create
    head :no_content
  end
  
  private
  
  def prepare_urls
    @urls = (params[:urls] || []).map{|e| e.unaccent}
  end
  
  def prepare_jobs
    @urls.each do |url|
      next if url !~ /^http/
      EventsWorker.perform_async({
        :url => url.unaccent,
        :developer_id => @developer.id,
        :action => Event::REQUEST,
        :ip_address => "0.0.0.0"
      })
    end
  end
end