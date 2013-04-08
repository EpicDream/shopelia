class Api::V1::Callback::OrdersController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  skip_before_filter :authenticate_developer!
  before_filter :retrieve_order
  before_filter :prepare_params
  
  def_param_group :context do
    param :context, Hash, :required => true, :action_aware => true do
      param :state, String, "Current order's state. Must be equal to server order's state to process callback", :required => true
      param :message, String, "Information about current processing", :required => false
    end
  end
  
  api :PUT, "/callback/orders/:uuid", "Callback an order"
  param_group :context
  def update
    if @order.state_name.eql?(@state)

      @order.update_attribute :message, @message
      
      if @content.present?
        @order.advance(@content)
      end
      
      head :no_content
    else
      render json: {}, status: 412
    end
  end

  private
  
  def retrieve_order
    @order = Order.where(:uuid => params[:id]).first!
  end
  
  def prepare_params
    data = JSON.parse(params[:data])
    @state = data["session"]["state"]
    case data["verb"]
    when "message"
      @message = data["content"]
    when "terminate"
      @content = { "response" => "ok" }
    when "confirm"
      @content = data["content"]
    when "failure"
      @content = { "status" => "error" }
    end
  end
  
end
