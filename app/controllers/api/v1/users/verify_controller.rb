class Api::V1::Users::VerifyController < Api::V1::BaseController

  api :POST, "/users/verify", "Verify a user by pincode or credit card details"
  param :pincode, String, "pincode", :required => false
  param :cc_num, String, "last 4 numbers of credit card", :required => false
  param :cc_month, String, "expiration month of credit card (MM)", :required => false
  param :cc_year, String, "expiration year of credit card (YY)", :required => false  
  def create
    if current_user.verify(params)
      head :no_content
    else
      head :unauthorized
    end
  end

end
