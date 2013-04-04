class Api::V1::Phones::LookupController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  before_filter :retrieve_number

  api :GET, "/phones/:number/lookup", "Lookup a phone number in reverse directory"
  def index
    render json: Scrapers::ReverseDirectory.lookup(@number)
  end

  private
  
  def retrieve_number
    @number = params[:phone_id].to_s
  end
  
end
