class Admin::ThemesController < Admin::AdminController

  def index
    @themes = Theme.order('created_at desc')
  end
  
  def edit
    @theme = Theme.find(params[:id])
    @theme.hashtags.build
    
    render 'edit', layout:false
  end
  
  def create
    theme = Theme.create(params[:theme])
    flash[:error] = theme.errors.full_messages unless theme.valid?
    redirect_to admin_themes_path
  end
  
  def update
    theme = Theme.find(params[:id])
    theme.update_attributes(params[:theme])
    redirect_to admin_themes_path
  end
  
  def destroy
    theme = Theme.find(params[:id])
    unless theme.destroy
      flash[:error] = "Cette collection n'a pas pu être détruite"
    end
    redirect_to admin_themes_path
  end
  
  def add_new_look
    theme = Theme.find(params[:theme_id])
    look = Look.find(params[:id])
    theme.looks << look rescue PG::UniqueViolation
    respond_to do |format|
      format.json { render json:{}, status: :ok}
    end
  end
  
end
