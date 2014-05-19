class Api::Flink::Mailjet::UnsubscribesController < Api::Flink::BaseController
  skip_before_filter :authenticate_flinker!
  skip_before_filter :retrieve_device
  skip_before_filter :authenticate_developer!
  
  def create
    if params[:unsubscribe] && flinker = Flinker.where(email:params[:unsubscribe][:email]).first
      flinker.update_attributes(newsletter:false)
    end
    
    render json:{}, status:200
  end
end
