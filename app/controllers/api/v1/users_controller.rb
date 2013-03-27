class Api::V1::UsersController < Api::V1::BaseController
  before_filter :retrieve_user

  def_param_group :user do
    param :user, Hash, :required => true, :action_aware => true do
      param :email, /\A[^@]+@[^@]+\z/, :desc => "Email of the user", :required => true
      param :password, String, "Password of the user", :required => true
      param :password_confirmation, String, "Password confirmation", :required => true
      param :first_name, String, "First name of the user", :required => true
      param :last_name, String, "Last name of the user", :required => true
    end
  end

  api :GET, "/users/:id", "Get an user"
  def show
    render json: @user
  end

  api :PUT, "/users/:id", "Update an user"
  param_group :user
  def update
    if @user.update_attributes(params[:user])
      head :no_content
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  api :DELETE, "/users/:id", "Destroy an user"
  def destroy
    @user.destroy
    head :no_content
  end
  
  private
  
  def retrieve_user
    @user = current_user
  end
  
end
