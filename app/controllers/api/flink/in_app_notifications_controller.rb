class Api::Flink::InAppNotificationsController < Api::Flink::BaseController
  def index
    @notifications = InAppNotification.available_notifications_for(current_flinker)
    
    render json: { 
      notifications: ActiveModel::ArraySerializer.new(@notifications) 
    }
  end
end
