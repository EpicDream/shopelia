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
  
end
