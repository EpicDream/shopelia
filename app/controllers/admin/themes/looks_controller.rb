class Admin::Themes::LooksController < Admin::AdminController
  
  def create
    theme = Theme.find(params[:theme_id])
    look = Look.find(params[:look_id])
    theme.append_look(look)
    respond_to do |format|
      format.json { render json:{}, status: :ok}
    end
  end
end
