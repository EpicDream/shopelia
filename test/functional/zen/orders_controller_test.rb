require 'test_helper'

class Zen::OrdersControllerTest < ActionController::TestCase
  include Devise::TestHelpers
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

    put :update, id:@order.to_param, order:{confirmation:"yes"}
    assert_redirected_to "/zen/orders/#{@order.uuid}"
    
    assert_equal :preparing, @order.reload.state
  end

  test "should update and cancel order" do
    @order.state_name = "querying"
    @order.save

    put :update, id:@order.to_param, order:{confirmation:"no"}
    assert_response 302
    
    assert_equal :failed, @order.reload.state
  end

end

