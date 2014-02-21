class Api::Flink::LooksController < Api::Flink::BaseController
  LOOKS_ORDER = "looks.published_at desc"
  
  skip_before_filter :authenticate_flinker!
  before_filter { epochs_to_dates [:updated_after, :published_before, :published_after] }
  
  api :GET, "/looks", "Get looks"
  def index
    render unauthorized and return unless current_flinker
    render json: { looks: serialize(looks, scope:scope()) }
  end

  private

  def looks
    case
    when params[:looks_ids]  
      Look.published.where(uuid:params[:looks_ids])
    when params[:liked]
      flinker = Flinker.where(id:params[:flinker_id]).first || current_flinker
      FlinkerLike.likes_for(flinker).includes(:look).order(LOOKS_ORDER).map(&:look)
    when params[:updated_after]
      Look.of_flinker_followings(current_flinker)
      .published_after(params[:updated_after])
      .order('updated_at asc')
      .paginate(pagination)
    when params[:flinker_ids]
      Look.where(flinker_id:params[:flinker_ids])
      .published_between(params[:published_after], params[:published_before])
      .order(LOOKS_ORDER)
      .paginate(pagination)
    else
      Look.of_flinker_followings(current_flinker)
      .published_between(params[:published_after], params[:published_before])
      .order(LOOKS_ORDER)
      .paginate(pagination)
    end
  end

end