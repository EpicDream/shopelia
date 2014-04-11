class Api::Flink::ThemesController < Api::Flink::BaseController
  
  api :GET, "/themes", "Get themes with minimal informations"
  def index
    render json: { themes: serialize(themes, scope: { use_cache: use_cache? }) }
  end
  
  api :GET, "/themes/<id>", "Get theme details, looks and/or flinkers"
  def show
    render json: ThemeSerializer.new(Theme.find(params[:id]), scope:{ full:true, use_cache: use_cache? })
  end
  
  private
  
  def themes
    unless use_cache?
      Theme.pre_published_or_published
    else
      Theme.published(true)
    end
  end
  
  #TOFIX:How can we get a current flinker without device !!??
  def use_cache?
    current_flinker.device && current_flinker.device.real_user? 
  end

end
