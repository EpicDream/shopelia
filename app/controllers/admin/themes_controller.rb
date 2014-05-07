class Admin::ThemesController < Admin::AdminController

  def index
    @themes = Theme.of_series(params[:series]).order('series desc, position asc')
  end
  
  def edit
    @theme = Theme.find(params[:id])
    @theme.hashtags.build
    @theme.countries.build if @theme.countries.none?
    render 'edit', layout:false
  end
  
  def create
    theme = Theme.create(params[:theme])
    flash[:error] = theme.errors.full_messages unless theme.valid?
    redirect_to admin_themes_path
  end
  
  def update
    @theme = Theme.find(params[:id])
    updated = @theme.update_attributes(params[:theme])
    
    render json:{}, status: updated ? :ok : :error
  end
  
  def destroy
    theme = Theme.find(params[:id])
    unless theme.destroy
      flash[:error] = "Cette collection n'a pas pu être détruite"
    end
    
    redirect_to admin_themes_path
  end
  
end
