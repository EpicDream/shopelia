# -*- encoding : utf-8 -*-
require 'test_helper'

class ProductSerializerTest < ActiveSupport::TestCase
  
  setup do
    @product = products(:usbkey)
  end
  
  test "it should correctly serialize product" do
    product_serializer = ProductSerializer.new(@product)
    hash = product_serializer.as_json
      
    assert_equal @product.id, hash[:product][:id]
    assert_equal @product.name, hash[:product][:name]
    assert_equal @product.brand, hash[:product][:brand]
    assert_equal @product.reference, hash[:product][:reference]
    assert_equal @product.url, hash[:product][:url]
    assert_equal @product.image_url, hash[:product][:image_url]
    assert_equal @product.description, hash[:product][:description]
    assert_equal @product.merchant.name, hash[:product][:merchant][:name]
    assert_equal @product.product_master_id, hash[:product][:master_id]
    assert_equal 1, hash[:product][:versions].count
    
    product_versions(:usbkey).update_attribute :available, false
    product_serializer = ProductSerializer.new(@product)
    hash = product_serializer.as_json
    
    assert_equal 0, hash[:product][:versions].count
  end

end

