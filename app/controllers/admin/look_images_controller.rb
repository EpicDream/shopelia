class Admin::LookImagesController < Admin::AdminController
  before_filter :retrieve_item, :only => [:update, :destroy]

  def update
    updated = @item.update_attributes(params[:look_image])
    respond_to do |format|
      format.json { render json:"{}", status: updated ? :ok : :error } 
    end
  end    

  def destroy
    @item.destroy
    respond_to do |format|
      format.json { render json:"{}", status: :ok } 
    end
  end    

  private

  def retrieve_item
    @item = LookImage.find(params[:id])
  end
end