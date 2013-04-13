# -*- encoding : utf-8 -*-
require 'test_helper'

class OrderSerializerTest < ActiveSupport::TestCase
  fixtures :orders, :products, :merchants, :order_items
  
  setup do
    @item = order_items(:item1)
    @item.price_product = 5.5
    @item.price_delivery = 2
    @item.product_title = "product_title"
    @item.product_image_url = "product_image_url"
    @item.price_text = "price_text"
    @item.delivery_text = "delivery_text"
    @item.save
  end
  
  test "it should correctly serialize order item" do
    item_serializer = OrderItemSerializer.new(@item)
    hash = item_serializer.as_json[:order_item]
      
    assert_equal @item.quantity, hash[:quantity]
    assert_equal @item.price_product, hash[:price_product]
    assert_equal @item.price_delivery, hash[:price_delivery]
    assert_equal @item.product_title, hash[:product_title]
    assert_equal @item.product_image_url, hash[:product_image_url]
    assert_equal @item.price_text, hash[:price_text]
    assert_equal @item.delivery_text, hash[:delivery_text]
    assert hash[:product].present?
  end

end

