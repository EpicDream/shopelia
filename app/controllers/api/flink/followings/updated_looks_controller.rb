class Api::Flink::Followings::UpdatedLooksController < Api::Flink::BaseController
  LOOKS_ORDER = "looks.updated_at asc"
  
  before_filter { epochs_to_dates [:updated_after] }
  
  api :GET, "/looks", "Get looks updated of current flinker followings"
  def index
    render unauthorized and return unless current_flinker
    render json: { looks: serialize(looks, scope:scope()) }
  end

  private

  def looks
    Look.of_flinker_followings(current_flinker)
    .updated_after(params[:updated_after])
    .order(LOOKS_ORDER)
    .paginate(pagination)
  end

end