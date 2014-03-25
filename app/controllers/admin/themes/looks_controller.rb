class Admin::Themes::LooksController < Admin::AdminController
  
  def index
    @theme = Theme.find(params[:theme_id])
    render partial: 'index'
  end
  
  def create
    theme = Theme.find(params[:theme_id])
    look = Look.find(params[:look_id])
    theme.append_look(look)
    respond_to do |format|
      format.json { render json:{}, status: :ok}
    end
  end
  
  def destroy
    @theme = Theme.find(params[:theme_id])
    look = Look.find(params[:id])
    @theme.remove_look(look)
    render partial: 'index'
  end
  
end
