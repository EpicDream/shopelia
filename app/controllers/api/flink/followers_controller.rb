class Api::Flink::FollowersController < Api::Flink::BaseController
  FLINKERS_ORDER = "username asc"
  
  def index
    flinker = Flinker.where(id:params[:flinker_id]).first || current_flinker
    flinkers = paged(flinker.followers.order(FLINKERS_ORDER))
    render json: { 
      flinkers:serialize(flinkers),
      has_next:@has_next
    }
  end
  
end