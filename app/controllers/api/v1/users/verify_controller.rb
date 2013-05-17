class Api::V1::Users::VerifyController < Api::V1::BaseController

  api :POST, "/users/verify", "Verify a user by pincode or credit card details"
  param :data, Hash, "pincode or cc_num (last 4 digits), cc_month and cc_year", :required => true
  def create
    if current_user.verify(params[:data])
      head :no_content
    else
      head :unauthorized
    end
  end

end
