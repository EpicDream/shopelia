class Api::Flink::ThemesController < Api::Flink::BaseController
  
  api :GET, "/themes", "Get themes with minimal informations"
  def index
    render json: { themes: serialize(themes) }
  end
  
  api :GET, "/themes/<id>", "Get theme details, looks and/or flinkers"
  def show
    render json: ThemeSerializer.new(Theme.find(params[:id]), scope:{ full:true })
  end
  
  private
  
  def themes
    if development?
      Theme.pre_published_or_published
    else
      themes = Theme.published(true)
      country_id = current_flinker.country.try(:id) || Country.en.id
      themes.delete_if { |theme|
        theme.country_ids.any? && !theme.country_ids.include?(country_id) 
      }
    end
  end
  
  def development?
    current_flinker.device && !current_flinker.device.real_user? 
  end

end
