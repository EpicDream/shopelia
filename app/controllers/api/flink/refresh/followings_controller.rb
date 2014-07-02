class Api::Flink::Refresh::FollowingsController < Api::Flink::BaseController
  
  before_filter { 
    epochs_to_dates [:updated_before, :updated_after] 
  }
  
  def index
    @flinker = Flinker.where(id:params[:flinker_id]).first || current_flinker
    @followings = flinkers(follow: true)
    @unfollowings = flinkers(follow: false)

    render json: {
      followings: {
        flinkers: serialize(@followings) 
      }.merge(timestamps @followings), 
      unfollowings: { 
        flinkers: serialize(@unfollowings)
      }.merge(timestamps @unfollowings)
    }
  end

  private
  
  def timestamps collection
    return {} unless collection.first
    { min_timestamp: collection.first.follow_updated_at.to_i, 
      max_timestamp: collection.last.follow_updated_at.to_i}
  end
  
  def flinkers follow: true
    skop = follow ? :followings : :unfollowings
    @flinker.send(skop)
    .followings_between(params[:updated_after], params[:updated_before])
    .order("flinker_follows.updated_at asc")
    .paginate(pagination)
  end
end