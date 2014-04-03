class Api::Flink::Flinkers::PasswordsController < Api::Flink::BaseController
  skip_before_filter :authenticate_flinker!

  def create
    flinker = Flinker.where(email:params[:email]).first
    if flinker
      flinker.send_reset_password_instructions
      render success
    else
      render unauthorized
    end
  end
  
end
