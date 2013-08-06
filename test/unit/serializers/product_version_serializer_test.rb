# -*- encoding : utf-8 -*-
require 'test_helper'

class ProductVersionSerializerTest < ActiveSupport::TestCase
  
  setup do
    @product = product_versions(:usbkey)
  end
  
  test "it should correctly serialize product version" do
    product_serializer = ProductVersionSerializer.new(@product)
    hash = product_serializer.as_json
      
    assert_equal @product.id, hash[:product_version][:id]
    assert_equal @product.name, hash[:product_version][:name]
    assert_equal @product.image_url, hash[:product_version][:image_url]
    assert_equal @product.description, hash[:product_version][:description]
    assert_equal @product.size, hash[:product_version][:size]
    assert_equal @product.color, hash[:product_version][:color]
    assert_equal @product.price, hash[:product_version][:price]
    assert_equal @product.price_shipping, hash[:product_version][:price_shipping]
    assert_equal @product.price_strikeout, hash[:product_version][:price_strikeout]
    assert_equal @product.shipping_info, hash[:product_version][:shipping_info]
    assert_equal 1, hash[:product_version][:available]    
  end

end

