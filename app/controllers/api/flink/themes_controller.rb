class Api::Flink::ThemesController < Api::Flink::BaseController
  
  api :GET, "/themes", "Get themes with minimal informations"
  def index
    render json: { themes: serialize(Theme.published(true)) }
  end
  
  api :GET, "/themes/<id>", "Get theme details, looks and/or flinkers"
  def show
    render json: ThemeSerializer.new(Theme.find(params[:id]), scope:{ full:true })
  end

end
