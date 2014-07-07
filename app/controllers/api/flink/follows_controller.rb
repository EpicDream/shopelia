class Api::Flink::FollowsController < Api::Flink::BaseController
  before_filter :retrieve_flinker
  
  def index
    render json:ActiveModel::ArraySerializer.new(@flinker.followings)
  end

  def create
    params[:follows].each { |following_id| 
      FlinkerFollow.follow(@flinker.id, following_id) 
    }
    head :no_content
  end

  def destroy
    FlinkerFollow.unfollow(@flinker.id, params[:id]) 
    head :no_content
  end
  
  private
  
  def retrieve_flinker
    @flinker = Flinker.where(id:params[:flinker_id]).first || current_flinker
  end
end
