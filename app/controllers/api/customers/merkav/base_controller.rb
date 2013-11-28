class Api::Customers::Merkav::BaseController < Api::ApiController

  def ensure_merkav_api_key!
    render json: { error:I18n.t('developers.unauthorized') }, status: :unauthorized if @developer.name != "Merkav"
  end
end