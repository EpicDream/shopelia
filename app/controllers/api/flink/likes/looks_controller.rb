class Api::Flink::Likes::LooksController < Api::Flink::BaseController
  LOOKS_ORDER = "looks.flink_published_at desc"
  
  api :GET, "/looks", "Get liked looks of current flinker or flinker with flinker_id"
  def index
    render unauthorized and return unless current_flinker
    render json: { looks: serialize(looks, scope:scope()) }
  end

  private

  def looks
    flinker = Flinker.where(id:params[:flinker_id]).first || current_flinker
    ids = FlinkerLike.likes_for(flinker).map(&:resource_id)
    Look.where(id:ids).order(LOOKS_ORDER).paginate(pagination)
  end

end