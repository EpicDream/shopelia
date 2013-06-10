require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  fixtures :orders

  setup do
    @order = orders(:elarch_rueducommerce)
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
    @order.prepared_price_total = 20
    @order.state_name = "querying"
    @order.save

    put :update, id:@order.to_param, confirmation:"yes"
    assert_response 302
    
    assert_equal :processing, @order.reload.state
  end

  test "should update and cancel order" do
    @order.state_name = "querying"
    @order.save

    put :update, id:@order.to_param, confirmation:"no"
    assert_response 302
    
    assert_equal :failed, @order.reload.state
  end

end

