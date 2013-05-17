# -*- encoding : utf-8 -*-
require 'test_helper'

class OrderSerializerTest < ActiveSupport::TestCase
  fixtures :orders, :products, :merchants, :order_items
  
  setup do
    @order = orders(:elarch_rueducommerce)
    @order.message = "message"
    @order.expected_price_product = 100
    @order.expected_price_shipping = 10
    @order.expected_price_total = 110
    @order.prepared_price_product = 100
    @order.prepared_price_shipping = 10
    @order.prepared_price_total = 110
    @order.billed_price_product = 100
    @order.billed_price_shipping = 10
    @order.billed_price_total = 110
    @order.shipping_info = "Shipping information"
    @order.questions = [
      { "id" => "1",
        "text" => "Color?",
        "options" => [
          { "blue" => "Bleu" },
          { "red" => "Rouge" }
        ]
      }
    ]
    @order.save
  end
  
  test "it should correctly serialize order" do
    order_serializer = OrderSerializer.new(@order)
    hash = order_serializer.as_json
      
    assert_equal @order.uuid, hash[:order][:uuid]
    assert_equal @order.state_name, hash[:order][:state]
    assert_equal 100, hash[:order][:expected_price_product]
    assert_equal 10, hash[:order][:expected_price_shipping]
    assert_equal 110, hash[:order][:expected_price_total]
    assert_equal 100, hash[:order][:prepared_price_product]
    assert_equal 10, hash[:order][:prepared_price_shipping]
    assert_equal 110, hash[:order][:prepared_price_total]
    assert_equal 100, hash[:order][:billed_price_product]
    assert_equal 10, hash[:order][:billed_price_shipping]
    assert_equal 110, hash[:order][:billed_price_total]
    assert_equal "Shipping information", hash[:order][:shipping_info]
    assert_equal @order.merchant.name, hash[:order][:merchant][:name]
    assert hash[:order][:products].present?
    assert !hash[:order][:questions].present?
    
    @order.state_name = "pending_answer"
    order_serializer = OrderSerializer.new(@order)
    hash = order_serializer.as_json    
    assert hash[:order][:questions].present?
    assert_equal 1, hash[:order][:questions].count
  end

end

