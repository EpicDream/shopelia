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
    assert_equal @item.product.id, hash[:id]
    assert_equal @item.product_version_id, hash[:product_version_id]
    assert_equal Linker.monetize(@item.product.url), hash[:url]
    assert_equal [JSON.parse(@item.product_version.option1), JSON.parse(@item.product_version.option2), JSON.parse(@item.product_version.option3), JSON.parse(@item.product_version.option4)].to_set, hash[:options].to_set
  end

  test "it should send empty options" do
    @item.product_version.update_attributes(option1:nil, option2:nil, option3:nil, option4:nil)
    item_serializer = OrderItemSerializer.new(@item)
    hash = item_serializer.as_json[:order_item]

    assert hash[:options].empty?
  end
end