class Api::Flink::ThemesController < Api::Flink::BaseController
  THEME_ORDER = 'rank asc'
  
  api :GET, "/themes", "Get themes with minimal informations"
  def index
    render json: { themes: serialize(themes, scope:{ en:current_flinker.english_language? }) }
  end
  
  api :GET, "/themes/<id>", "Get theme details, looks and/or flinkers"
  def show
    render json: ThemeSerializer.new(
      Theme.find(params[:id]), scope:{ full:true, en:current_flinker.english_language? }
    )
  end
  
  private
  
  def themes
    if development?
      Theme.pre_published_or_published.for_country(current_flinker.country).order(THEME_ORDER)
    else
      Theme.published(true).for_country(current_flinker.country).order(THEME_ORDER)
    end
  end
  
  def development?
    current_flinker.device && !current_flinker.device.real_user? 
  end
  
end
