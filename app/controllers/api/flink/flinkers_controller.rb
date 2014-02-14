class Api::Flink::FlinkersController < Api::Flink::BaseController
  
  api :GET, "/flinkers", "Get flinkers"
  def index
    render json: { flinkers: flinkers() }
  end

  private

  def flinkers
    query = params[:username] ? Flinker.with_username_like(params[:username]) : Flinker.publishers.with_looks
    query = query.of_country(params[:country_iso]).includes(:country)
    flinkers = query.paginate(pagination())
    ActiveModel::ArraySerializer.new(flinkers)
  end

end
