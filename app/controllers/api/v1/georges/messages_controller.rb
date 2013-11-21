class Api::V1::Georges::MessagesController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  before_filter :retrieve_message, :only => [:update, :read]

  api :GET, "/api/georges/messages", "Get all messages for device"
  param :timestamp, Integer, "Timestamp of last received message from API", :required => true
  def index
    messages = @device.messages.where("created_at > ?", Time.at(params[:timestamp].to_i).to_datetime)
    render json: messages.map{ |m| m.as_push }
  end

  api :POST, "/api/georges/messages", "Create message"
  param :message, String, "Message", :required => true
  def create
    message = @device.messages.build(content:params[:message])

    if message.save
      render json: { timestamp:Time.now.to_i }
    else
      render json: message.errors, status: :unprocessable_entity
    end
  end

  api :PUT, "/api/georges/messages/:id", "Update message"
  def update
    if @message.update_attributes(params[:message])
      head :no_content
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  api :GET, "/api/georges/messages/:id/read", "Mark message as read"
  def read
    @message.update_attributes(read_at:Time.now)
    head :no_content
  end

  def retrieve_message
    @message = Message.find(params[:id])
  end
 end