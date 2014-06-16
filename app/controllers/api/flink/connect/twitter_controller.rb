class Api::Flink::Connect::TwitterController < Api::Flink::BaseController
  
  def create
    user = TwitterUser.init current_flinker, params[:token], params[:token_secret]
    render json: {}, status: user ? :ok : :not_found
  end
end