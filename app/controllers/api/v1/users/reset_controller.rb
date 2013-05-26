class Api::V1::Users::ResetController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  before_filter :retrieve_user

  api :POST, "/users/reset", "Sent email instruction to reset password"
  param :email, Hash, "Email to send instructions to", :required => true
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
    email = params[:email]
    head :unprocessable_entity and return unless email
    @user = User.find_by_email(email)
  end

end
