class Admin::Georges::DevicesController < Admin::AdminController

  def index
    respond_to do |format|
      format.html
      format.json { render json: ::Georges::DevicesDatatable.new(view_context) }
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