class Admin::MessagesController < Admin::AdminController
  def index
    @messages = Message.last_messages
  end

  def show
    @message =  Message.find(params[:id])
    @messages = Message.where(device_id: @message.device_id)
  end
end
