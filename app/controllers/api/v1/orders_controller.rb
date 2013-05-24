class Api::V1::OrdersController < Api::V1::BaseController
  before_filter :retrieve_order, :only => :show  
  
  def_param_group :order do
    param :order, Hash, :required => true, :action_aware => true do
      param :urls, Array, "Array of URL of the products to buy", :required => true
      param :address_id, Integer, "Reference to the delivery address", :required => true
      param :payment_card_id, Integer, "Reference to the payment card to be billed", :required => true
      param :expected_price_total, Float, "Expected total order price. Order will be fullfilled only if checkout price will match", :required => true
    end
  end  
  
  api :POST, "/orders", "Create a new order"
  param_group :order
  def create
    @order = Order.new(params[:order].merge({ user_id: current_user.id }))

    if @order.save
      @order.start
      render json: OrderSerializer.new(@order).as_json, status: :created
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  api :GET, "/orders/:uuid", "Show an order"
  def show
    render json: OrderSerializer.new(@order).as_json
  end

  private
  
  def retrieve_order
    @order = Order.where(:uuid => params[:id], :user_id => current_user.id).first!
  end
  
end
