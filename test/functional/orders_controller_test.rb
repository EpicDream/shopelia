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

end

