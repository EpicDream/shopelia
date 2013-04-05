# -*- encoding : utf-8 -*-
require 'test_helper'

class ProductSerializerTest < ActiveSupport::TestCase
  fixtures :products, :merchants
  
  setup do
    @product = products(:usbkey)
  end
  
  test "it should correctly serialize product" do
    product_serializer = ProductSerializer.new(@product)
    hash = product_serializer.as_json
      
    assert_equal @product.id, hash[:product][:id]
    assert_equal @product.name, hash[:product][:name]
    assert_equal @product.url, hash[:product][:url]
    assert_equal @product.image_url, hash[:product][:image_url]
    assert_equal @product.merchant.name, hash[:product][:merchant][:name]
  end

end

