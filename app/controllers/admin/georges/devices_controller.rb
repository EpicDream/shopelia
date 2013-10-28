class Admin::Georges::DevicesController < Admin::AdminController
  def index
    @devices = Device.where(pending_answer:true).uniq
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
