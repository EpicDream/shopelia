class Admin::InAppNotificationsController < Admin::AdminController
  
  def new
    @notification = InAppNotification.new
    @notification.image = Image.new
  end
  
  def show
    
  end
  
  def update
    
  end
  
  def create
    
  end
end