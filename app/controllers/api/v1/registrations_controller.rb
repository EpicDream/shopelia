class Api::V1::RegistrationsController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  before_filter :prepare_user_hash
  
  api :POST, "/users", "Register a new user"
  param_group :user, Api::V1::UsersController
  def create
    @user = User.find_by_email_and_visitor(@user_hash[:email], true)
    if @user.nil?
      @user = User.create(@user_hash)
    else
      @user.update_attributes(@user_hash)
    end
    
    if @user.persisted?
      render json: UserSerializer.new(@user).as_json.merge({:auth_token => @user.authentication_token}), status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end
  
  private
  
  def prepare_user_hash
    @user_hash = params[:user].merge({
      :developer_id => @developer.id,
      :ip_address => request.remote_ip,
      :visitor => false
    })
  end
  
end
