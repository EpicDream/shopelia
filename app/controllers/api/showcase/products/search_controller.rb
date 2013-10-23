class Api::Showcase::Products::SearchController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  before_filter :prepare_params
  before_filter :prepare_result
  before_filter :log_scan
  before_filter :prepare_jobs

  def index
    render :json => @result
  end

  private
  
  def prepare_params
    @ean = params[:ean]
    @tracker = params[:tracker]
    if params[:visitor]
      @device = Device.fetch(params[:visitor], request.env['HTTP_USER_AGENT'])
    else
      render :json => {"Error" => "Missing visitor param"}, status: :bad_request and return
    end
  end

  def prepare_result
    @result = Search::Ean.get(@ean)
  end

  def log_scan
    ScanLog.create(
      ean:@ean,
      device_id:@device.id,
      prices_count:@result[:urls].count)
    LeftronicLiveScanWorker.perform_async({
      ean:@ean,
      prices_count:@result[:urls].count,
      name:@result[:name], 
      image_url:@result[:image_url]})
  end

  def prepare_jobs
    (@result[:urls] || []).each do |url|
      next if url !~ /^http/
      EventsWorker.perform_async({
        :url => url.unaccent,
        :developer_id => @developer.id,
        :action => Event::VIEW,
        :tracker => @tracker,
        :device_id => @device.id,
        :ip_address => request.remote_ip
      })
    end
  end
end