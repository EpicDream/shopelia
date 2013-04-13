require 'test_helper'

class Api::V1::OrdersControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  fixtures :users, :orders, :merchants, :order_items

  setup do
    @user = users(:elarch)
    sign_in @user
    @order = orders(:elarch_rueducommerce)
  end

  test "it should create order" do
    assert_difference('Order.count', 1) do
      post :create, order: { urls: ["http://www.rueducommerce.fr/productA"] }, format: :json
    end
    
    assert_response :success
  end

  test "it should show order" do
    get :show, id: @order.uuid, format: :json
    assert_response :success
  end

end

