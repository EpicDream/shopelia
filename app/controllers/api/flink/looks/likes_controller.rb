class Api::Flink::Looks::LikesController < Api::Flink::BaseController
  before_filter :retrieve_look
  
  def create
    like = FlinkerLike.new(
      flinker_id:current_flinker.id,
      resource_type:FlinkerLike::LOOK,
      resource_id:@look.id)

    if like.save
      head :no_content
    else
      render json: like.errors, status: :unprocessable_entity
    end
  end

  def destroy
    FlinkerLike.of_flinker(current_flinker).of_look(@look).first.toggle
    head :no_content
  end

  private

  def retrieve_look
    @look = Look.find_by_uuid!(params[:look_id])
  end
end