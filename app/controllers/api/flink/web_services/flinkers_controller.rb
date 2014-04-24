class Api::Flink::WebServices::FlinkersController < Api::Flink::BaseController
  skip_before_filter :authenticate_flinker!
  
  def show
    flinker = Flinker.find_by_uuid params[:uuid]

    if flinker
      render json:WS::FlinkerSerializer.new(flinker), status:200
    else
      render json:{}, status: 404
    end
  end
  
end