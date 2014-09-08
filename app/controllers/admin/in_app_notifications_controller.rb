class Admin::InAppNotificationsController < Admin::AdminController
  
  def new
    @notification = InAppNotification.new
  end
  
  def show
    @notification = InAppNotification.find(params[:id])
  end
  
  def update
    @notification = InAppNotification.find(params[:id])
    @notification.update_attributes!(params[:in_app_notification])
    redirect_to admin_in_app_notification_path(@notification)
  rescue
    flash[:error] = "Une erreur s'est produite, vérifier si le lien/identifiant est correct"
    render 'show'
  end
  
  def create
    @notification = InAppNotification.new(params[:in_app_notification])
    @notification.save!
    redirect_to admin_in_app_notification_path(@notification)
  rescue
    flash[:error] = "Une erreur s'est produite, vérifier si le lien/identifiant est correct"
    render 'new'
  end
end