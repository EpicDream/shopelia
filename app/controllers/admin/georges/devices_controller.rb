class Admin::Georges::DevicesController < Admin::AdminController
  before_filter :retrieve_device, :only => :update

  def index
    if params[:device_id].present?
      @device = Device.find(params[:device_id])
      @messages = @device.messages.order(:created_at)
    end
  end

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