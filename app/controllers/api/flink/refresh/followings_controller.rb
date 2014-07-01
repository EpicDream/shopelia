class Api::Flink::Refresh::FollowingsController < Api::Flink::BaseController
  FLINKERS_ORDER = "username asc"
  
  before_filter { 
    epochs_to_dates [:updated_before, :updated_after] 
  }
  
  def index
    @flinker = Flinker.where(id:params[:flinker_id]).first || current_flinker
    render json: {
      followings: serialize(flinkers(follow: true)), 
      unfollowings: serialize(flinkers(follow: false))
    }
  end

  private
  
  def flinkers follow: true
    skop = follow ? :followings : :unfollowings
    @flinker.send(skop)
    .followings_between(params[:updated_after], params[:updated_before])
    .order(FLINKERS_ORDER)
    .paginate(pagination)
  end
end