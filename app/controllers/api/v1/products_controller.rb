class Api::V1::ProductsController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  before_filter :prepare_product, :only => :index
  before_filter :prepare_products, :only => :create
  before_filter :prepare_scope
  
  api :GET, "/api/products", "Get product information"
  param :url, String, "Url of the product to get", :required => true
  def index
    render :json => @product ? ProductSerializer.new(@product, scope:@scope).as_json[:product] : {}
  end

  api :POST, "/api/products", "Get products information"
  param :urls, Hash, "Urls of the product to get", :required => true
  def create
    render :json => ActiveModel::ArraySerializer.new(@products, scope:@scope)
  end

  private

  def prepare_product
    @product = Product.fetch(params[:url])
    if @product.present? && @product.persisted?
      # retrieve created versions
      @product.reload
    else
      @product = nil 
    end
  end
  
  def prepare_products
    @products = []
    (params[:urls] || []).each do |url|
      product = Product.fetch(url)
      @products << product.reload if product.present? && product.persisted?
    end
  end

  def prepare_scope
    @scope = { developer:@developer }
  end
  
end
