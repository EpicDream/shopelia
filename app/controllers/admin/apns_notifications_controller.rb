class Admin::ApnsNotificationsController < Admin::AdminController
  
  def new
    @notification = ApnsNotification.new
  end
  
  def show
    @notification = ApnsNotification.find(params[:id])
  end
  
  def update
    @notification = ApnsNotification.find(params[:id])
    @notification.update_attributes!(params[:apns_notification])
    redirect_to admin_apns_notification_path(@notification)
  rescue
    flash[:error] = "Une erreur s'est produite, vérifier si le lien/identifiant est correct"
    render 'show'
  end
  
  def create
    @notification = ApnsNotification.new(params[:apns_notification])
    @notification.save!
    redirect_to admin_apns_notification_path(@notification)
  rescue
    flash[:error] = "Une erreur s'est produite, vérifier si le lien/identifiant est correct"
    render 'new'
  end
  
  def test
    notification = ApnsNotification.last
    notification.apns_test
    redirect_to admin_apns_notification_path(notification)
  end
  
  def send_to_flinkers
    ApnsNotification.last.send_to_all_flinkers
    redirect_to new_admin_apns_notification_path
  end
  
end
