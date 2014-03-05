class Api::Flink::Followings::LooksController < Api::Flink::BaseController
  LOOKS_ORDER = "looks.flink_published_at desc"
  
  skip_before_filter :authenticate_flinker!
  before_filter { epochs_to_dates [:flink_published_before, :flink_published_after] }
  
  api :GET, "/looks", "Get looks of current flinker followings"
  def index
    render unauthorized and return unless current_flinker
    render json: { looks: serialize(looks, scope:scope.merge(include_liked_by_friends:true)) }
  end

  private

  def looks
    Look.of_flinker_followings(current_flinker)
    .flink_published_between(params[:flink_published_after], params[:flink_published_before])
    .order(LOOKS_ORDER)
    .paginate(pagination)
  end

end