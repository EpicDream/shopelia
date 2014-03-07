class Api::Flink::AvatarsController < Api::Flink::BaseController
  
  def create
    current_flinker.avatar = params[:avatar]
    current_flinker.save!
    render success
  end
end