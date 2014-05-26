class Api::Flink::BestLooksController < Api::Flink::BaseController
  LOOKS_ORDER = "looks.flink_published_at desc"
  
  before_filter { 
    epochs_to_dates [:flink_published_before, :flink_published_after] 
  }
  
  def index
    render unauthorized and return unless current_flinker
    render json: { looks: serialize(looks, scope:scope()) }
  end

  private

  def looks
    Look.best(params[:flink_published_before], params[:flink_published_after])
    .order(LOOKS_ORDER)
    .paginate(pagination)
  end

end