class Api::Flink::Likes::LooksController < Api::Flink::BaseController
  LOOKS_ORDER = "looks.flink_published_at desc"
  
  api :GET, "/likes/looks", "Get liked looks of current flinker or flinker with flinker_id"
  def index
    render unauthorized and return unless current_flinker
    render json: { looks: serialize(looks, scope:scope()) }
  end

  private

  def looks
    flinker = (params[:flinker_id] && Flinker.find_by_id(params[:flinker_id])) || current_flinker
    Look.liked_by(flinker).order(LOOKS_ORDER).paginate(pagination)
  end

end