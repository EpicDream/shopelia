# -*- encoding : utf-8 -*-
require 'test_helper'

class OrderSerializerTest < ActiveSupport::TestCase
  fixtures :orders, :products, :merchants, :order_items
  
  setup do
    @order = orders(:elarch_rueducommerce)
    @order.message = "message"
    @order.price_product = 100
    @order.price_delivery= 10
    @order.price_total = 110
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
    assert_equal @order.price_product, hash[:order][:price_product]
    assert_equal @order.price_delivery, hash[:order][:price_delivery]
    assert_equal @order.price_total, hash[:order][:price_total]
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

