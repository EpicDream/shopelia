class Admin::Georges::DevicesController < Admin::AdminController

  def index
    @devices = Device.all
    respond_to do |format|
      format.html
    end
  end

  def update
    @device =  Device.find(params[:id])
    if @device.update_attributes(params[:device])
      respond_to do |format|
        format.html {
          redirect_to admin_georges_devices_url
        }
      end
    end
  end
end