class Flink::LooksController < ApplicationController
  layout "flink"

  def show
    @look = Look.with_uuid(params[:id]).first
    @look ||= Look.find(params[:id])

    @matched_products = []
    @similar_products = []
    at_least_one_product_is_purchasable = products_have_at_least_one_purchasable? @look.look_products
    for product in @look.look_products do
      hash = hash_from_product(product, at_least_one_product_is_purchasable)
      if product_is_similar? product then
        @similar_products << hash
      else
        @matched_products << hash
      end
    end
  end

  private
  def hash_from_product product, render_shop_badge
    { code: product.code, brand: product.brand, monetized_url: product_monetized_url(product), is_hot: product_is_hot?(product), render_shop_badge: render_shop_badge }
  end

  def product_is_similar? product
    product.vendor_products.first && product.vendor_products.first.similar
  end

  def product_is_purchasable? product
    product.vendor_products.first && product.vendor_products.first.url && product.vendor_products.first.url.length > 0
  end

  def product_is_hot? product
    product.vendor_products.first && product.vendor_products.first.staff_pick
  end

  def product_monetized_url product
    product_is_purchasable?(product) ? product.vendor_products.first.url : ""
  end

  def products_have_at_least_one_purchasable? products
    for product in products
      return true if product_is_purchasable? product
    end
    return false
  end
end