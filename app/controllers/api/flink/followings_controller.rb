class Api::Flink::FollowingsController < Api::Flink::BaseController
  FLINKERS_ORDER = "username asc"
  before_filter :touch_session_open, only: :index
  before_filter :retrieve_flinker
  
  def index
    render json: {
      flinkers:serialize(paged @flinker.followings.order(FLINKERS_ORDER)),
      has_next:@has_next
    }
  end

  def create
    params[:followings_ids].each { |following_id| 
      FlinkerFollow.follow(@flinker.id, following_id) 
    }
    head :no_content
  end

  def destroy
    params[:followings_ids].each { |following_id| 
      FlinkerFollow.unfollow(@flinker.id, following_id) 
    }
    head :no_content
  end
  
  private
  
  def retrieve_flinker
    @flinker = Flinker.where(id:params[:flinker_id]).first || current_flinker
  end
  
  def touch_session_open
    current_flinker && current_flinker.touch(:last_session_open_at)
  end
end
