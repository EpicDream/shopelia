class Api::V1::Places::DetailsController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  before_filter :retrieve_params

  api :GET, "/places/details/:reference", "Gets full details for a place"
  def show
    render json: Google::PlacesApi.details(@reference)
  end

  private
  
  def retrieve_params
    @reference = params[:id].to_s
  end
  
end
