class Api::Flink::Looks::ProductsController < Api::Flink::BaseController
  skip_before_filter :authenticate_flinker!
  
  def index
    @look = Look.find_by_uuid!(params[:look_id])
    render json: ActiveModel::ArraySerializer.new(@look.look_products)
  end

end