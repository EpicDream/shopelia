class Api::V1::Places::AutocompleteController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  before_filter :retrieve_params

  api :GET, "/places/autocomplete", "Autocomplete an address"
  def index
    render json: Google::PlacesApi.autocomplete(@query, @lat, @lng)
  end

  private
  
  def retrieve_params
    @query = params[:query].to_s
    @lat = params[:lat]
    @lng = params[:lng]
  end
  
end
