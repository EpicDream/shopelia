class Admin::ImagesController < Admin::AdminController
  
  def update
    @image = LookImage.find params[:id]
    @image.crop params[:coordinates]
    redirect_to admin_look_path(@image.look)
  end
  
  def show
    @image = Image.find params[:id]
  end

end