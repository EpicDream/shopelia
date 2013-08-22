require 'test_helper'

class CartItemTest < ActiveSupport::TestCase
  
  setup do
    @cart = Cart.create(user_id:users(:elarch).id)
    @product_version = product_versions(:usbkey)
  end
  
  test "it should create cart item" do
    updated_at = @cart.updated_at
    item = CartItem.new(cart_id:@cart.id, product_version_id:@product_version.id)

    assert item.save, item.errors.full_messages.join(",")
    assert_equal @product_version.price, item.price
    assert_equal @product_version.price_shipping, item.price_shipping
    assert @cart.reload.updated_at > updated_at
  end

  test "it shouldn't allow creation of duplicate item" do
    CartItem.create(cart_id:@cart.id, product_version_id:@product_version.id)
    item = CartItem.new(cart_id:@cart.id, product_version_id:@product_version.id)

    assert !item.save
  end

  test "it should allow same item for different carts" do
    CartItem.create(cart_id:@cart.id, product_version_id:@product_version.id)
    item = CartItem.new(cart_id:Cart.create(user_id:users(:elarch).id).id, product_version_id:@product_version.id)  

    assert item.save
  end
end
