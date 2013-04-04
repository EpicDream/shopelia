require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  fixtures :users, :products, :merchants, :orders
  
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
  
  test "it should execute all ordering steps until success" do
    assert_equal :pending, @order.state
    @order.advance
    assert_equal :ordering, @order.state
    @order.advance
    assert_equal :pending_confirmation, @order.state
    @order.advance({ "response" => "ok" })
    assert_equal :paying, @order.state
    @order.advance
    assert_equal :success, @order.state
  end
  
  test "it should cancel order if user doesn't confirm" do
    assert_equal :pending, @order.state
    @order.advance
    assert_equal :ordering, @order.state
    @order.advance
    assert_equal :pending_confirmation, @order.state
    @order.advance({ "response" => "niet" })
    assert_equal :canceled, @order.state
  end

  test "it should stop at first error" do
    assert_equal :pending, @order.state
    @order.advance
    assert_equal :ordering, @order.state
    @order.advance({ "status" => "error" })
    assert_equal :error, @order.state
  end
  
end
