class Api::Showcase::Products::SearchController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  before_filter :prepare_params

  def index
    if @ean
      prixing = Prixing::Product.get(@ean)
      if prixing.empty? || prixing.is_a?(Hash)
        render :json => {}
      else
        result = PrixingWrapper.convert(prixing)
        prepare_jobs(result)
        render :json => result
      end
    else
      render :json => {}
    end
  end

  private
  
  def prepare_jobs result
    (result[:urls] || []).each do |url|
      next if url.blank?
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

  def prepare_params
    @ean = params[:ean]
    @tracker = params[:tracker]
    if params[:visitor]
      @device = Device.fetch(params[:visitor], request.env['HTTP_USER_AGENT'])
    else
      render :json => {"Error" => "Missing visitor param"}, status: :bad_request and return
    end
  end
end