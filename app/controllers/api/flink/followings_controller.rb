class Api::Flink::FollowingsController < Api::Flink::BaseController

  def index
    flinker = Flinker.where(id:params[:flinker_id]).first || current_flinker
    render json: {
      flinkers:serialize(paged flinker.followings),
      has_next:@has_next
    }
  end

  def create
    params[:followings_ids].each { |following_id| 
      FlinkerFollow.create(flinker_id:current_flinker.id, follow_id:following_id.to_i)
    }

    head :no_content
  end

  def destroy
    FlinkerFollow.where(flinker_id:current_flinker.id, follow_id:params[:id]).first.destroy
    head :no_content
  end
  
end
