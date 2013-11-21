# -*- encoding : utf-8 -*-
require 'test_helper'

class Viking::ProductSerializerTest < ActiveSupport::TestCase
  
  setup do
    @product = products(:usbkey)
  end
  
  test "it should correctly serialize product for viking" do
    product_serializer = Viking::ProductSerializer.new(@product)
    hash = product_serializer.as_json
      
    assert_equal @product.id, hash[:product][:id]
    assert_equal @product.url, hash[:product][:url]
    assert_equal @product.merchant_id, hash[:product][:merchant_id]
    assert !hash[:product][:batch_mode]
  end

  test "it should set batch mode" do
    Event.create(
      :product_id => @product.id,
      :action => Event::REQUEST,
      :developer_id => developers(:shopelia).id)

    product_serializer = Viking::ProductSerializer.new(@product.reload)
    hash = product_serializer.as_json
      
    assert hash[:product][:batch_mode]    
  end
end