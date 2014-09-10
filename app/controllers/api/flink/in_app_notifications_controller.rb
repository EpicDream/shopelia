class Api::Flink::InAppNotificationsController < Api::Flink::BaseController
  def index
    
    render json: { 
      notifications: ActiveModel::ArraySerializer.new(InAppNotification.notifications_for current_flinker) 
    }
  end
  
end
