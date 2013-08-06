require 'test_helper'

class Admin::OrdersControllerTest < ActionController::TestCase

  setup do
    @order = orders(:elarch_rueducommerce)
  end

  test "should show all orders" do
    get :index
    assert_response :success
  end
  
  test "should show one order" do
    get :show, id:@order.to_param
    assert_response :success
  end

end

