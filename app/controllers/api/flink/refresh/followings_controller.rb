class Api::Flink::Refresh::FollowingsController < Api::Flink::BaseController
  skip_before_filter :authenticate_flinker!
  
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
    unless collection.first
      timestamp = Time.now.to_i
      return { min_timestamp: timestamp, max_timestamp: timestamp } 
    end
    { min_timestamp: collection.last.follow_updated_at.to_i, 
      max_timestamp: collection.first.follow_updated_at.to_i}
  end
  
  def flinkers follow: true
    skop = follow ? :followings : :unfollowings
    @flinker.send(skop)
    .followings_between(params[:updated_after], params[:updated_before])
    .order("flinker_follows.updated_at desc")
    .paginate(pagination)
  end
end