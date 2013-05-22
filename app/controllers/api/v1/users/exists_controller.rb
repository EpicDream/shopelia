class Api::V1::Users::ExistsController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  before_filter :process_params

  api :POST, "/users/exists", "Check if user exists"
  param :data, Hash, "email key", :required => true
  def create
    if User.find_by_email(@email)
      head :no_content
    else
      head :not_found
    end
  end
  
  private
  
  def process_params
    @email = params[:data][:email] unless params[:data].nil?
    head :unprocessable_entity and return unless @email
  end

end
