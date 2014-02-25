class Api::Flink::FollowsController < Api::Flink::BaseController

  def index
    flinker = Flinker.where(id:params[:flinker_id]).first || current_flinker
    flinkers = Flinker.where(id:flinker.followings.map(&:id)).includes(:country)
    render json: ActiveModel::ArraySerializer.new(flinkers)
  end

  def create
    (params[:follows] || []).each do |id|
      FlinkerFollow.create(
       flinker_id:current_flinker.id,
       follow_id:id.to_i)
    end

    head :no_content
  end

  def destroy
    FlinkerFollow.where("flinker_id=? and follow_id=?", current_flinker.id, params[:id]).destroy_all
    head :no_content
  end
end
