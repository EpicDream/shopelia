class Admin::OrdersController < Admin::AdminController

  def index
    @orders = Order.page(params[:page]).order('created_at DESC')
  end

  def show
    @order = Order.find_by_uuid!(params[:id])
  end
  
end
