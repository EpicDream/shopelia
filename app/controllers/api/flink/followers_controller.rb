class Api::Flink::FollowersController < Api::Flink::BaseController

  def index
    flinker = Flinker.where(id:params[:flinker_id]).first || current_flinker
    flinkers = paged(flinker.followers)
    render json: { 
      flinkers:serialize(flinkers),
      has_next:@has_next
    }
  end
  
end