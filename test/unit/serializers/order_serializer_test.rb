# -*- encoding : utf-8 -*-
require 'test_helper'

class OrderSerializerTest < ActiveSupport::TestCase
  fixtures :orders, :products, :merchants
  
  setup do
    @order = orders(:elarch_usbkey)
    @order.message = "message"
    @order.price_product = 100
    @order.price_delivery= 10
    @order.price_total = 110
    @order.save
  end
  
  test "it should correctly serialize order" do
    order_serializer = OrderSerializer.new(@order)
    hash = order_serializer.as_json
      
    assert_equal @order.uuid, hash[:order][:uuid]
    assert_equal @order.state_name, hash[:order][:state]
    assert_equal @order.price_product, hash[:order][:price_product]
    assert_equal @order.price_delivery, hash[:order][:price_delivery]
    assert_equal @order.price_total, hash[:order][:price_total]
    assert_equal @order.merchant.name, hash[:order][:merchant][:name]
    assert_equal @order.product.name, hash[:order][:product][:name]
  end

end

