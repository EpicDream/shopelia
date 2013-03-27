class Api::V1::SessionsController < Api::V1::BaseController
  skip_before_filter :authenticate_user!, :only => :create
 
  api :POST, "/users/sign_in", "Sign in a user"
  param :email, String, "Email of the user", :required => true
  param :password, String, "Password of the user", :required => true
  def create
    resource = User.find_for_database_authentication(:email => params[:email])
    return invalid_login_attempt unless resource
 
    if resource.valid_password?(params[:password])
      sign_in(:user, resource)
      resource.ensure_authentication_token!
      render json: { auth_token:resource.authentication_token }
      return
    end
    invalid_login_attempt
  end
 
  api :DELETE, "/users/sign_out", "Sign out a user"
  param :email, String, "Email of the user", :required => true
  def destroy
    user = User.find_for_database_authentication(:email => params[:email])
    user.authentication_token =  nil
    if user.save
      render json: {}
    else
      render json: { error:user.errors.join(",") }, status: :unprocessable_entity
    end
  end
 
  protected
 
  def invalid_login_attempt
    render json: { error:I18n.t('devise.failure.invalid') }, status: :forbidden
  end
end
