class Api::V1::RegistrationsController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  
  api :POST, "/users", "Register a new user"
  param_group :user, Api::V1::UsersController
  def create
    @user = User.create(params[:user].merge({
      :developer_id => @developer.id,
      :ip_address => request.remote_ip
    }))

    if @user.persisted?
      render json: UserSerializer.new(@user).as_json.merge({:auth_token => @user.authentication_token}), status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end
  
end
