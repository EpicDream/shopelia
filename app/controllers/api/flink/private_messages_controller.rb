class Api::Flink::PrivateMessagesController < Api::Flink::BaseController
  
  def create
    render unauthorized and return unless current_flinker
    saved = PrivateMessage.create(attributes)
    render json: {}, status: saved ? :ok : :error
  end

  private
  
  def attributes
    look = Look.find_by_uuid(params[:look_uuid].scan(/^[^\-]+/))
    { look_id:look.id, flinker_id:current_flinker.id, target_id:params[:target_id], content:params[:content], answer:params[:answer]}
  end
  
end