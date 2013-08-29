require 'test_helper'

class CartTest < ActiveSupport::TestCase
  
  test "it should create cart for user" do
    cart = Cart.new(name:"Test", user_id:users(:elarch).id)
    assert cart.save, cart.errors.full_messages.join(",")
  end

  test "it shouldn't create carte without owner" do
    cart = Cart.new
    assert !cart.save
  end 
  
end
