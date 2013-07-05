class Api::V1::Users::VerifyController < Api::V1::BaseController

  api :POST, "/users/verify", "Verify a user by pincode or credit card details"
  param :pincode, String, "pincode", :required => false
  param :passwortd, String, "password", :required => false
  param :cc_num, String, "last 4 numbers of credit card", :required => false
  param :cc_month, String, "expiration month of credit card (MM)", :required => false
  param :cc_year, String, "expiration year of credit card (YY)", :required => false  
  def create
    delay = UserVerificationFailure.delay(current_user)
    if delay > 0
      render :json => { :delay => delay }, :status => 503
    elsif current_user.verify(params)
      render json: UserSerializer.new(current_user).as_json, :status => 204
    else
      head :unauthorized
    end
  end

end
