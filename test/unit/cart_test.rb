require 'test_helper'

class CartTest < ActiveSupport::TestCase
  
  test "it should create cart for user" do
    cart = Cart.new(name:"Test", user_id:users(:manu).id)
    assert cart.save, cart.errors.full_messages.join(",")
    assert_equal Cart::CHECKOUT, cart.kind
  end

  test "it shouldn't create carte without owner" do
    cart = Cart.new
    assert !cart.save
  end 
end