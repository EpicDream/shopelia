class Admin::ApnsNotificationsController < Admin::AdminController
  
  def new
    @notification = ApnsNotification.last || ApnsNotification.create
  end
  
  def update
    notification = ApnsNotification.last
    notification.update_attributes(params[:apns_notification])
    redirect_to new_admin_apns_notification_path
  end
  
  def test
    ApnsNotification.last.apns_test
    redirect_to new_admin_apns_notification_path
  end
  
  def send_to_flinkers
    ApnsNotificationWorker.perform_async(ApnsNotification.last.id)
    redirect_to new_admin_apns_notification_path
  end
  
end
