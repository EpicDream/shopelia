class Api::V1::RegistrationsController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  
  api :POST, "/users", "Register a new user"
  param_group :user, Api::V1::UsersController
  def create
    @user = User.new(params[:user].merge({:ip_address => request.remote_ip}))

    if @user.save
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end
  
end
