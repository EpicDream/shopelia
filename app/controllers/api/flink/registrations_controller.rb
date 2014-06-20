class Api::Flink::RegistrationsController < Api::Flink::BaseController
  skip_before_filter :authenticate_flinker!

  api :POST, "/flinkers", "Register a new flinker"
  def create
    @flinker = dev_temp_hack || Flinker.create(params[:flinker])
    if @flinker.persisted?
      render json: FlinkerSerializer.new(@flinker).as_json.merge({:auth_token => @flinker.authentication_token}), status: :created
    else
      render json: @flinker.errors, status: :unprocessable_entity
    end
  end
  
  def dev_temp_hack
    if params[:flinker][:email] == "test@flink.io"
      return Flinker.where(email: params[:flinker][:email]).first
    end
    nil
  end

end