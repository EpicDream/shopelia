class Api::Flink::AvatarsController < Api::Flink::BaseController
  
  def create
    Image.upload(params[:payload]) { |file| current_flinker.avatar = file  }
    current_flinker.save!
    render success
  end
end