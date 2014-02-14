class Api::Flink::FlinkersController < Api::Flink::BaseController
  DEFAULT_PAGE = 1
  DEFAULT_PER_PAGE = 10
  
  api :GET, "/flinkers", "Get flinkers"
  def index
    render json: { flinkers: flinkers() }
  end

  private

  def flinkers
    query = params[:username] ? Flinker.with_username_like(params[:username]) : Flinker.publishers.with_looks
    query = query.of_country(params[:country_iso]).includes(:country)
    flinkers = query.paginate(page:params[:page] || DEFAULT_PAGE, per_page: params[:per_page] || DEFAULT_PER_PAGE)
    ActiveModel::ArraySerializer.new(flinkers)
  end

end
