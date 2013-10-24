class Admin::Georges::MessagesController < Admin::AdminController
  before_filter :retrieve_device

  def index
    @messages = @device.messages.order(:created_at)
  end

  def create
    @message = @device.messages.build(params[:message].merge(from_admin:true))

    if @message.save
      redirect_to admin_georges_device_messages_url(@device)
    else
      render :action => 'index'
    end
  end

  private

  def retrieve_device
    @device = Device.find(params[:device_id])
  end
end