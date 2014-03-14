class Admin::LookImagesController < Admin::AdminController

  def update#TODO:Quick temp raw reorder, cause RankedModel do whatever with Rails3/Postgres and so has been removed
    params[:look_image][:display_orders].each do |id , pos|
      id, pos = [id, pos].map { |value| ActiveRecord::Base.sanitize(value) }
      Image.connection.execute("update images set display_order = #{pos} where id = #{id}")
    end
    respond_to do |format|
      format.json { render json:"{}", status: :ok } 
    end
  end    

  def destroy
    look_image.destroy
    respond_to do |format|
      format.json { render json:"{}", status: :ok } 
    end
  end    

  private

  def look_image
    @look_image ||= LookImage.find(params[:id])
  end
end