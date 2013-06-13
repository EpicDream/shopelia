class Admin::UsersController < Admin::AdminController
  
  
  def index
    respond_to do |format|
      format.html
      format.json { render json: UsersDatatable.new(view_context) }
    end
  end

  def show
    @user = User.find(params[:id])
  end
  
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    
    respond_to do |format|
      format.html { redirect_to admin_users_url }
      format.json { render json: {} }
    end
  end
  
end
