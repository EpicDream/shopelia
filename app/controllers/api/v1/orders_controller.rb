class Api::V1::OrdersController < Api::V1::BaseController
  before_filter :retrieve_order, :only => :show  
  
  def_param_group :order do
    param :order, Hash, :required => true, :action_aware => true do
      param :url, String, "URL of the product to buy", :required => true
    end
  end  
  
  api :POST, "/orders", "Create a new order"
  param_group :order
  def create
    @order = Order.new(params[:order].merge({ user_id: current_user.id }))

    if @order.save
      render json: @order, status: :created
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  api :GET, "/orders/:uuid", "Show an order"
  def show
    render json: @order
  end

  private
  
  def retrieve_order
    @order = Order.where(:uuid => params[:id], :user_id => current_user.id).first!
  end
  
end
