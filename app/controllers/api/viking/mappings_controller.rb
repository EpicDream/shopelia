class Api::Viking::MappingsController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  skip_before_filter :authenticate_developer!

  api :GET, "/mappings", "Get mapping by url"
  def index
    if params[:url].present? || params[:merchant_id].present?
      self.show
    else
      @mappings = Mapping.all
      render json: @mappings.to_json
    end
  end

  api :GET, "/mappings/:id", "Get mapping by id"
  def show
    if params[:url].present?
      @merchant = Merchant.from_url(params[:url])
      @mapping = @merchant.mapping if @merchant.present?
    elsif params[:merchant_id].present?
      @merchant = Merchant.find(params[:merchant_id])
      @mapping = @merchant.mapping if @merchant.present?
    else
      @mapping = Mapping.find(params[:id])
    end
    render json: @mapping.to_json
  end

  api :POST, "/mappings", "Create a new mapping"
  def create
    @mapping = Mapping.new(params[:data])
    if @mapping.save
      render json: @mapping, status: :created
    else
      render json: @mapping.errors, status: :unprocessable_entity
    end
  end

  api :PUT, "/mappings/:id", "Update mapping by id"
  def update
    @mapping = Mapping.find(params[:id])
    if @mapping.update_attributes(params[:data])
      head :no_content
    else
      render json: @mapping.errors, status: :unprocessable_entity
    end
  end
end
