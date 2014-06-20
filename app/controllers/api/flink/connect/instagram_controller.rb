class Api::Flink::Connect::InstagramController < Api::Flink::BaseController
  
  def create
    user = InstagramUser.init current_flinker, params[:token]
    render json: {}, status: user ? :ok : :not_found
  end
end