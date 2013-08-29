# -*- encoding : utf-8 -*-
require 'test_helper'

class CartSerializerTest < ActiveSupport::TestCase
  
  setup do
    @cart = Cart.create(user_id:users(:elarch).id)
    @product_version = product_versions(:usbkey)
    @item = CartItem.new(cart_id:@cart.id, product_version_id:@product_version.id)
  end
  
  test "it should correctly serialize cart item" do
    item_serializer = CartItemSerializer.new(@item)
    hash = item_serializer.as_json[:cart_item]
      
    assert_equal @item.product_version_id, hash[:product_version_id]
    assert_equal @item.uuid, hash[:uuid]
  end

end

