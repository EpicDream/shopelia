class Api::Flink::Hashtags::LooksController < Api::Flink::BaseController
  LOOKS_ORDER = "looks.id, looks.flink_published_at desc"
  
  skip_before_filter :authenticate_flinker!
  
  api :GET, "/hashtags/looks", "Get looks with comments containing at least one of the given hashtags"
  def index
    render unauthorized and return unless current_flinker
    render json: { looks: serialize(looks, scope:scope()) }
  end

  private

  def looks
    Look.with_comment_matching(params[:hashtag])
    .select('distinct on(looks.id, looks.flink_published_at) *')
    .order(LOOKS_ORDER)
    .paginate(pagination)
  end

end