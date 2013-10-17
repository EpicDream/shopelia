class Developers::TrackingController < Developers::DevelopersController
  before_filter :retrieve_product, :only => :destroy

  def index
    @products = current_developer.products.paginate(:page => params[:page])
  end

  def create
    DeveloperProductsWorker.perform_async({
      urls: params[:urls],
      developer_id: current_developer.id
    })
    redirect_to developers_tracking_index_path, notice: "Product urls added in scheduler. Refresh page in a few minutes to see results"
  end

  def destroy
    current_developer.products.delete(@product)

    respond_to do |format|
      format.json { head :ok }
    end
  end

  def refresh
    current_developer.products.update_all "versions_expires_at = null"
    current_developer.products.each do |p|
      Event.create(
        :product_id => p.id,
        :action => Event::REQUEST,
        :developer_id => current_developer.id)
    end

    redirect_to developers_tracking_index_path, notice: "Products are scheduled to be refreshed immediately. Reload page to check out updates."
  end 

  private

  def retrieve_product
    @product = Product.find(params[:id])
  end
end