class Api::Flink::Looks::SharingsController < Api::Flink::BaseController

  def create
    saved = LookSharing.on(params[:social_network]).for(look_id:params[:look_id], flinker_id:current_flinker.id)
    head saved ? :ok : :error
  end
  
end
