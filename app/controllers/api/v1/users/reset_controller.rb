class Api::V1::Users::ResetController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  before_filter :retrieve_user

  api :POST, "/users/reset", "Sent email instruction to reset password"
  param :data, Hash, "email key", :required => true
  def create
    if @user
      @user.send_reset_password_instructions
      head :no_content
    else
      head :not_found
    end
  end
  
  private
  
  def retrieve_user
    email = params[:data][:email] unless params[:data].nil?
    head :unprocessable_entity and return unless email
    @user = User.find_by_email(email)
  end

end
