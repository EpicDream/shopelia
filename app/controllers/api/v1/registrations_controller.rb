class Api::V1::RegistrationsController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  
  api :POST, "/users", "Create an user"
  def create
    @user = User.new(params[:user])

    if @user.save
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end
  
end
