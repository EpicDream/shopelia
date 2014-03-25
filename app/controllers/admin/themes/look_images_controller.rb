class Admin::Themes::LookImagesController < Admin::AdminController
  
  def index
    theme = Theme.find(params[:theme_id])
    @look_images = theme.looks.map { |look| look.look_images}.flatten
    render 'index', layout:false
  end
  
end
