class Api::Flink::Refresh::LikesController < Api::Flink::BaseController
  LOOKS_ORDER = "looks.flink_published_at desc"
  
  before_filter { 
    epochs_to_dates [:updated_before, :updated_after] 
  }
  
  def index
    @flinker = (params[:flinker_id] && Flinker.find_by_id(params[:flinker_id])) || current_flinker
    render json: { 
      liked_looks: serialize(looks(liked: true), scope:scope()),
      unliked_looks: serialize(looks(liked: false), scope:scope())
    }
  end

  private
  
  def looks liked: true
    skop = liked ? :liked_by : :unliked_by
    Look.send(skop, @flinker)
    .likes_between(params[:updated_after], params[:updated_before])
    .order(LOOKS_ORDER)
    .paginate(pagination)
  end

end