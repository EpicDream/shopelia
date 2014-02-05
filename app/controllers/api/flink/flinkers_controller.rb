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
      flinkers = Flinker.publishers.with_looks
      ActiveModel::ArraySerializer.new(flinkers, scope:@scope)
    end
  end

  def retrieve_flinkers
    if params[:page].present?
      @page = params[:page]
      @per_page = params[:per_page] || 10
      query = Flinker.publishers.with_looks
      if params[:staff_pick].present?
        query = query.where(staff_pick: params[:staff_pick].to_i == 1)
      end
      query = query.of_country(params[:country_iso]) unless params[:country_iso].blank?
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
