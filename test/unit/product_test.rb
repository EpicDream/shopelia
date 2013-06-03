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

end
