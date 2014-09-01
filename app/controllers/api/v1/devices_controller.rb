class Api::V1::DevicesController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  before_filter :retrieve_device

  def_param_group :device do
    param :device, Hash, :required => true, :action_aware => true do
      param :push_token, String, "Push token for GCM", :required => false
      param :referrer, String, "Referrer for Google play installation", :required => false
      param :os, String, "OS name of device", :required => false
      param :os_version, String, "OS version of device", :required => false
      param :version, String, "Shopelia version running on device", :required => false
      param :build, Integer, "Shopela build number running of device", :required => false
      param :phone, String, "Phone type of device", :required => false
    end
  end

  param_group :device
  def update
    if @device.update_attributes(params[:device])
      head :no_content
    else
      render json: @device.errors, status: :unprocessable_entity
    end
  end
  
  private
  
  def retrieve_device
    @device = Device.find_or_create_by_uuid(params[:id])
  end  
end