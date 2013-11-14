class Api::V1::GeorgesController < Api::V1::BaseController
  skip_before_filter :authenticate_user!

  api :GET, "/api/georges/status", "Get Georges status"
  def status
    render json: {
      status: GeorgesStatus.get,
      message: GeorgesStatus.message
    }
  end
end