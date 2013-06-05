class Admin::UsersController < Admin::AdminController
  helper_method :sort_column, :sort_direction
  
  def index
    @users = User.page(params[:page]).order(sort_column + " " + sort_direction)
  end

  def show
    @user = User.find(params[:id])
  end
  
  private
  
  def sort_column
    User.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end
  
end
