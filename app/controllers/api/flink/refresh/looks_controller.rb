class Api::Flink::Refresh::LooksController < Api::Flink::BaseController
  skip_before_filter :authenticate_flinker!
  
  def index
    render json: { looks: serialize(looks, scope:scope(), each_serializer:LookLightSerializer) }
  end

  private

  def looks
    Look.published.where(uuid:params[:uuids])
  end

end