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
    unless current_flinker.device.real_user?
      Theme.pre_published_or_published
    else
      Theme.published(true)
    end
  end

end
