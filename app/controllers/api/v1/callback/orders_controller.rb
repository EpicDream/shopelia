class Api::V1::Callback::OrdersController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  skip_before_filter :authenticate_developer!
  before_filter :retrieve_order
  before_filter :prepare_params

  api :PUT, "/callback/orders/:uuid", "Callback an order"
  param :verb, String, "Action type", :required => true
  param :content, String, "Information about current processing", :required => false
  def update
    @order.process(@verb, @content)
    head :no_content
  end

  private
  
  def retrieve_order
    @order = Order.where(:uuid => params[:id]).first!
  end
  
  def prepare_params
    @verb = params[:verb]
    @content = params[:content] || {}
  end
  
end
