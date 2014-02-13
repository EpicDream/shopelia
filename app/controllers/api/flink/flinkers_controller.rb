class Api::Flink::FlinkersController < Api::Flink::BaseController
  before_filter :retrieve_flinkers, :only => :index
  before_filter :prepare_scope
  
  api :GET, "/flinkers", "Get flinkers"
  def index
    render json: {
      flinkers: @flinkers_json
    }
  end

  private

  def flinkers_cache
    Rails.cache.fetch([:flinker], :expires_in => 1.hour) do
      flinkers = Flinker.publishers.with_looks.includes(:country)
      ActiveModel::ArraySerializer.new(flinkers, scope:@scope)
    end
  end

  def retrieve_flinkers #TODO redo this fucking code
    if params[:page].present?
      @page = params[:page]
      @per_page = params[:per_page] || 10
      query = Flinker.publishers.with_looks.includes(:country)
      query = query.staff_pick(params[:staff_pick].to_i == 1)
      query = query.with_username_like(params[:username])
      query = query.of_country(params[:country_iso])
      @flinkers = query.paginate(page:@page, per_page:@per_page)
      @flinkers_json = ActiveModel::ArraySerializer.new(@flinkers, scope:@scope)
    else
      @flinkers_json = flinkers_cache
    end
  end

  def prepare_scope
    @scope = { developer:@developer, device:@device, flinker:current_flinker, short:true }
  end
end
