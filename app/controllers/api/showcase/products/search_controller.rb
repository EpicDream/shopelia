class Api::Showcase::Products::SearchController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  before_filter :prepare_params

  def index
    if @ean
      prixing = Prixing::Product.get(@ean)
      if prixing.empty? || prixing.is_a?(Hash)
        render :json => {}
      else
        r = PrixingWrapper.convert(prixing)
        generate_events(r[:urls])
        render :json => r
      end
    else
      render :json => {}
    end
  end

  private
  
  def generate_events urls
    Event.from_urls(
      :urls => urls,
      :developer_id => @developer.id,
      :action => Event::VIEW,
      :tracker => @tracker,
      :device_id => @device.id,
      :ip_address => request.remote_ip)
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