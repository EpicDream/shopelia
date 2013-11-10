class Admin::Georges::DevicesController < Admin::AdminController
  before_filter :retrieve_device, :only => :update

  def update
    @device.update_attributes(params[:device])
    redirect_to admin_georges_devices_url
  end

  def lobby
    respond_to do |format|
      format.js
    end
  end

  private

  def retrieve_device
    @device = Device.find(params[:id])
  end
end