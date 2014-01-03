class Api::Flink::FollowsController < Api::Flink::BaseController

  def index
    flinkers = Flinker.where(id:current_flinker.flinker_follows.map(&:follow_id))
    render json: ActiveModel::ArraySerializer.new(flinkers)
  end

  def create
    (params[:follows] || []).each do |id|
      FlinkerFollow.create!(
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