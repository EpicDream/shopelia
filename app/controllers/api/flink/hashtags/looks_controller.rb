class Api::Flink::Hashtags::LooksController < Api::Flink::BaseController
  
  api :GET, "/hashtags/looks", "Get looks with hashtags matching given hashtag"
  def index
    render unauthorized and return unless current_flinker
    render json: { looks: serialize(looks, scope:scope()) }
  end

  private

  def looks
    Look.search_for_api([params[:hashtag]].compact).paginate(pagination)
  end

end