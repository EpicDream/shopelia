# -*- encoding : utf-8 -*-
require 'test_helper'

class Viking::ProductSerializerTest < ActiveSupport::TestCase
  fixtures :products
  
  setup do
    @product = products(:usbkey)
  end
  
  test "it should correctly serialize product" do
    product_serializer = Viking::ProductSerializer.new(@product)
    hash = product_serializer.as_json
      
    assert_equal @product.id, hash[:product][:id]
    assert_equal @product.url, hash[:product][:url]
  end

end

