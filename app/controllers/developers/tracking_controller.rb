class Developers::TrackingController < Developers::DevelopersController

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
  end
end