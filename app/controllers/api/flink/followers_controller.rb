class Api::Flink::FollowersController < Api::Flink::BaseController

  def index
    flinker = Flinker.where(id:params[:flinker_id]).first || current_flinker
    render json: ActiveModel::ArraySerializer.new(flinker.followers)
  end
  
end