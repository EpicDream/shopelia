class Api::Flink::RegistrationsController < Api::Flink::BaseController
  skip_before_filter :authenticate_flinker!
  before_filter :prepare_flinker_hash

  api :POST, "/flinkers", "Register a new flinker"
  def create
    @flinker = Flinker.create(@flinker_hash)
    if @flinker.persisted?
      render json: FlinkerSerializer.new(@flinker).as_json.merge({:auth_token => @flinker.authentication_token}), status: :created
    else
      render json: @flinker.errors, status: :unprocessable_entity
    end
  end

  private

  def prepare_flinker_hash
    @flinker_hash = params[:flinker].merge({
                                         :developer_id => @developer.id,
                                     })
  end

end