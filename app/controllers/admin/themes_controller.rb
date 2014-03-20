class Admin::ThemesController < Admin::AdminController

  def index
    @themes = Theme.order('created_at desc')
  end
  
  def create
    theme = Theme.create(params[:theme])
    flash[:error] = theme.errors.full_messages unless theme.valid?
    redirect_to admin_themes_path
  end
  
  def update
    
  end
  
  def destroy
    theme = Theme.find(params[:id])
    unless theme.destroy
      flash[:error] = "Cette collection n'a pas pu être détruite"
    end
    redirect_to admin_themes_path
  end
  
end
