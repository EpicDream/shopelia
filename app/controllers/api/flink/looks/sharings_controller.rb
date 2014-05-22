class Api::Flink::Looks::SharingsController < Api::Flink::BaseController

  def create
    look = Look.find_by_uuid(params[:look_id].scan(/^[^\-]+/))
    saved = look && LookSharing.on(params[:social_network]).for(look_id:look.id, flinker_id:current_flinker.id)
    head saved ? :ok : :error
  end
  
end
