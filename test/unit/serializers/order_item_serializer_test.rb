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
    assert_equal @item.product_version.option1, hash[:option1].to_json
    assert_equal @item.product_version.option2, hash[:option2].to_json
    assert_equal @item.product_version.option3, hash[:option3].to_json
    assert_equal @item.product_version.option4, hash[:option4].to_json
  end

end

