class Admin::Themes::FlinkersController < Admin::AdminController
  
  def index
    @theme = Theme.find(params[:theme_id])
    render partial: 'index'
  end
  
  def create
    theme = Theme.find(params[:theme_id])
    flinker = Flinker.find(params[:flinker_id])
    theme.append_flinker(flinker)
    respond_to do |format|
      format.json { render json:{}, status: :ok}
    end
  end
  
  def destroy
    @theme = Theme.find(params[:theme_id])
    flinker = Flinker.find(params[:id])
    @theme.remove_flinker(flinker)
    render partial: 'index'
  end
  
end