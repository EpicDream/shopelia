class Api::V1::Georges::MessagesController < Api::V1::BaseController
  skip_before_filter :authenticate_user!

  api :POST, "/api/georges/messages", "Create message"
  param :message, String, "Message", :required => true
  def create
    message = @device.messages.build(content:params[:message])

    if message.save
      head :no_content
    else
      render json: message.errors, status: :unprocessable_entity
    end
  end
 end