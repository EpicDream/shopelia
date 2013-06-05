# -*- encoding : utf-8 -*-
require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  fixtures :merchants, :products
  
  test "it should create product" do
    product = Product.new(
      :name => 'Product',
      :merchant_id => merchants(:rueducommerce).id,
      :url => 'http://www.rueducommerce.fr/product',
      :image_url => 'http://www.rueducommerce.fr/image')
    assert product.save, product.errors.full_messages.join(",")
  end
  
  test "it should create product from url" do
    product = Product.new(:url => 'http://www.rueducommerce.fr/product')
    assert product.save, product.errors.full_messages.join(",")
    assert_equal merchants(:rueducommerce).id, product.merchant_id
  end
  
  test "it should prevent product creation from unsupported merchant" do
    product = Product.new(:url => 'http://www.bla.fr/product')
    assert !product.save
    assert_equal I18n.t('products.errors.unsupported_merchant'), product.errors.full_messages.first
  end

  test "it should unaccent url" do
    product = Product.new(:url => "http://www.rueducommerce.fr/product-é")
    assert product.save, product.errors.full_messages.join(",")
    assert_equal "http://www.rueducommerce.fr/product-e", product.url
  end

  test "it should monetize url" do
    product = Product.new(:url => "http://www.amazon.fr/Brother-Telecopieur-photocopieuse-transfert-thermique/dp/B0006ZUFUO?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&tag=prixing-web-21&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B0006ZUFUO")
    assert product.save, product.errors.full_messages.join(",")
    assert_equal "http://www.amazon.fr/Brother-Telecopieur-photocopieuse-transfert-thermique/dp/B0006ZUFUO?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&tag=shopelia-21&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B0006ZUFUO", product.url
  end
  
  test "it should fetch existing product" do
    assert_equal products(:headphones), Product.fetch("http://www.rueducommerce.fr/productB")
  end
  
  test "it should create and fetch new product" do
    assert_difference('Product.count', 1) do
      Product.fetch("http://www.rueducommerce.fr/productC")
    end
  end
  
end
