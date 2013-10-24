class Admin::Georges::MessagesController < Admin::AdminController
  before_filter :prepare_message_params , :only => [:create]

  def index
    @device = Device.find(params[:device_id])
    @messages = Message.where(device_id:@device.id)
  end

  def create
    @device = Device.find(params[:device_id])
    @message = Message.create(@message_hash)
    @message.device_id = @device.id
    if @message.save!
      @device.pending_answer = false
      @device.save
      redirect_to admin_georges_device_messages_url(@device)
    else
      @message.errors.full_messages
    end
  end


  private

  def prepare_message_params
    @message_hash = params[:message].merge({
                                         :from_admin => true,
                                     })
  end

end
