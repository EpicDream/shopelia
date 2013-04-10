require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  fixtures :users, :products, :merchants, :orders, :payment_cards
  
  setup do
    @user = users(:elarch)
    @product = products(:usbkey)
    @merchant = merchants(:rueducommerce)
    @order = orders(:elarch_usbkey)
  end
  
  test "it should create order" do
    order = Order.new(
      :user_id => @user.id,
      :product_id => @product.id,
      :merchant_id => @merchant.id)
    assert order.save, order.errors.full_messages.join(",")
    assert_equal :pending, order.state
    assert order.uuid
  end
  
  test "it should create order from url" do
    order = Order.new(
      :user_id => @user.id,
      :url => "http://www.rueducommerce.fr/productA")
    assert order.save, order.errors.full_messages.join(",")
  end
  
  test "it should start order" do
    @order.start
    assert_equal :ordering, @order.state
  end
    
end
