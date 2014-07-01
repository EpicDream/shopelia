class Api::Flink::Looks::LikesController < Api::Flink::BaseController
  before_filter :retrieve_look
  
  def create
    if like = FlinkerLike.toggle_or_create(current_flinker, @look)
      head :no_content
    else
      render json: like.errors, status: :unprocessable_entity
    end
  end

  def destroy
    FlinkerLike.toggle_or_create(current_flinker, @look)
    head :no_content
  end

  private

  def retrieve_look
    @look = Look.find_by_uuid!(params[:look_id])
  end
end