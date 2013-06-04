class Api::V1::Limonetik::OrdersController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  skip_before_filter :authenticate_developer!
  before_filter :retrieve_order
  before_filter :prepare_params

  api :PUT, "/limonetik/orders/:uuid", "Callback an order from Limonetik back office"
  param :status, String, "Status of the CVD transaction (success, failure, refund)", :required => true
  param :amount, Integer, "Amount in eurocents of the CVD transaction", :required => true
  param :limonetik_order_id, Integer, "Reference to the Limonetik order", :required => true
  def update
    head :no_content
  end

  private
  
  def retrieve_order
    @order = Order.where(:uuid => params[:id]).first!
  end
  
  def prepare_params
    @status = params[:status]
    @amount = params[:amount]
    @l_order_id = [:limonetik_order_id]
    render json:"Invalid parameters", status: :unprocessable_entity and return if @status.blank? || @amount.blank? || @l_order_id.blank?
  end
  
end
