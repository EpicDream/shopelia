class Api::Flink::Hashtags::LooksController < Api::Flink::BaseController
  LOOKS_ORDER = "looks.flink_published_at desc"
  
  api :GET, "/looks", "Get looks with comments containing at one of the given hashtags"
  def index
    render unauthorized and return unless current_flinker
    render json: { looks: serialize(looks, scope:scope()) }
  end

  private

  def looks
    Look.with_comment_matching(params[:hashtag])
    .order(LOOKS_ORDER)
    .paginate(pagination)
  end

end