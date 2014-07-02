class Api::Flink::Refresh::LikesController < Api::Flink::BaseController
  LOOKS_ORDER = "looks.flink_published_at desc"
  
  before_filter { 
    epochs_to_dates [:updated_before, :updated_after] 
  }
  
  def index
    @flinker = (params[:flinker_id] && Flinker.find_by_id(params[:flinker_id])) || current_flinker
    @likes = looks(liked: true)
    @unlikes = looks(liked: false)

    render json: {
      likes: {
        looks: serialize(@likes, scope:scope()) 
      }.merge(timestamps @likes), 
      unlikes: { 
        looks: serialize(@unlikes, scope:scope())
      }.merge(timestamps @unlikes)
    }
  end

  private
  
  def timestamps collection
    return {} unless collection.first
    { min_timestamp: collection.first.like_updated_at.to_i, 
      max_timestamp: collection.last.like_updated_at.to_i}
  end
  
  def looks liked: true
    skop = liked ? :liked_by : :unliked_by
    Look.send(skop, @flinker)
    .likes_between(params[:updated_after], params[:updated_before])
    .order(LOOKS_ORDER)
    .paginate(pagination)
  end

end