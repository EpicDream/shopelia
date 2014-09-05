class Admin::ApnsNotificationsController < Admin::AdminController
  
  def new
    @notification = ApnsNotification.last || ApnsNotification.create
  end
  
  def update
    @notification = ApnsNotification.last
    @notification.update_attributes(params[:apns_notification])
    redirect_to new_admin_apns_notification_path
  rescue
    flash[:error] = "Une erreur s'est produite, vérifier si le lien/identifiant est correct"
    render 'new'
  end
  
  def test
    ApnsNotification.last.apns_test
    redirect_to new_admin_apns_notification_path
  end
  
  def send_to_flinkers
    ApnsNotification.last.send_to_all_flinkers
    redirect_to new_admin_apns_notification_path
  end
  
end
