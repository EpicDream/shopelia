class Admin::InAppNotificationsController < Admin::AdminController
  
  def new
    @notification = InAppNotification.new
    @notification.image = Image.new
  end
  
  def show
    @notification = InAppNotification.find(params[:id])
  end
  
  def update
    @notification = InAppNotification.find(params[:id])
    @notification.update_attributes!(params[:in_app_notification])
    redirect_to admin_in_app_notification_path(@notification)
  rescue
    flash.now[:error] = @notification.errors.full_messages
    render 'show'
  end
  
  def create
    @notification = InAppNotification.new(params[:in_app_notification])
    @notification.save!
    redirect_to admin_in_app_notification_path(@notification)
  rescue => e
    @notification.image = Image.new
    flash.now[:error] = @notification.errors.full_messages
    render 'new'
  end
end