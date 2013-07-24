require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @order = orders(:elarch_rueducommerce)
    @order.order_items.first.update_attribute :price, 10
    @order.order_items.second.update_attribute :price, 10
    @order.prepared_price_total = 20
    @order.prepared_price_shipping = 0
    @order.prepared_price_product = 20
    @order.state_name = "querying"
    @order.save!
  end

  test "should show order" do
    get :show, id:@order.to_param
    assert_response :success
  end
  
  test "should respond to not found" do
    get :show, id:"aaa"
    assert_response :not_found
  end
  
  test "should update and confirm order" do
    put :update, id:@order.to_param, order:{confirmation:"yes"}
    assert_response 302
    
    assert_equal :preparing, @order.reload.state
  end

  test "should update and cancel order" do
    put :update, id:@order.to_param, order:{confirmation:"no"}
    assert_response 302
    
    assert_equal :failed, @order.reload.state
  end
  
  test "should confirm order" do
    get :confirm, id:@order.to_param

    assert_response 302
    assert_equal :preparing, @order.reload.state
  end

  test "should cancel order" do
    get :cancel, id:@order.to_param

    assert_response 302
    assert_equal :failed, @order.reload.state
  end

end

