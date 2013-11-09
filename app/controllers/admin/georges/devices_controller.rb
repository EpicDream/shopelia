class Admin::Georges::DevicesController < Admin::AdminController
  before_filter :retrieve_device, :only => :update

  def index
  end

  def update
    @device.update_attributes(params[:device])
    redirect_to admin_georges_devices_url
  end

  private

  def retrieve_device
    @device = Device.find(params[:id])
  end
end