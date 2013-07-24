# -*- encoding : utf-8 -*-
require 'test_helper'

class OrderSerializerTest < ActiveSupport::TestCase
  
  setup do
    @item = order_items(:item1)
    @item.update_attribute :price, 5.5
  end
  
  test "it should correctly serialize order item" do
    item_serializer = OrderItemSerializer.new(@item)
    hash = item_serializer.as_json[:order_item]
      
    assert_equal @item.quantity, hash[:quantity]
    assert_equal @item.price, hash[:price]
    assert hash[:product].present?
  end

end

