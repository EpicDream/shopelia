class Api::Flink::RegistrationsController < Api::Flink::BaseController
  skip_before_filter :authenticate_flinker!

  api :POST, "/flinkers", "Register a new flinker"
  def create
    @flinker = Flinker.create(params[:flinker])
    if @flinker.persisted?
      render json: FlinkerSerializer.new(@flinker).as_json.merge({:auth_token => @flinker.authentication_token}), status: :created
    else
      render json: @flinker.errors, status: :unprocessable_entity
    end
  end

end