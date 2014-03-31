class Api::Flink::ThemesController < Api::Flink::BaseController
  
  api :GET, "/themes", "Get themes with minimal informations"
  
  def index
    render json: { themes: themes() }
  end

  private

  def themes
    themes = Theme.published(true)
    serialize themes
  end

end
