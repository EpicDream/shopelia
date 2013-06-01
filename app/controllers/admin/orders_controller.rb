class Admin::OrdersController < Admin::AdminController
  helper_method :sort_column, :sort_direction
  
  def index
    @orders = Order.page(params[:page]).order(sort_column + " " + sort_direction)
  end

  def show
    @order = Order.find_by_uuid!(params[:id])
  end
  
  private
  
  def sort_column
    Order.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end
  
end
