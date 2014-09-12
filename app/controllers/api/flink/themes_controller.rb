class Api::Flink::ThemesController < Api::Flink::BaseController
  THEME_ORDER = 'position asc'
  skip_before_filter :authenticate_flinker!, only: :index
  
  api :GET, "/themes", "Get themes with minimal informations"
  def index
    render json: { themes: serialize(themes, scope: scope().merge({ lang: lang() })) }
  end
  
  api :GET, "/themes/<id>", "Get theme details, looks and/or flinkers"
  def show
    render json: ThemeSerializer.new(
      Theme.find(params[:id]), scope: scope().merge({ full:true, lang: lang() })
    )
  end
  
  private
  
  def themes
    if Device.developer?(current_flinker)
      Theme.pre_published_or_published.for_country(country()).order(THEME_ORDER)
    else
      Theme.published(true).for_country(country()).order(THEME_ORDER)
    end
  end
  
  def lang
    params[:"x-user-language"] != 'fr_FR' ? :en : :fr
  end
  
  def country
    Country.find_by_iso(params[:"x-country-iso"]) || Country.fr
  end
  
end
