class Api::Flink::Flinkers::LooksController < Api::Flink::BaseController
  LOOKS_ORDER = "looks.flink_published_at desc"
  
  before_filter { epochs_to_dates [:flink_published_before, :flink_published_after] }
  
  api :GET, "/looks", "Get looks of given flinker via flinkers_ids"
  def index
    render unauthorized and return unless current_flinker
    render json: { looks: serialize(looks, scope:scope()) }
  end

  private

  def looks
    Look.where(flinker_id:params[:flinkers_ids])
    .flink_published_between(params[:flink_published_after], params[:flink_published_before])
    .order(LOOKS_ORDER)
    .paginate(pagination)
  end

end