require 'test_helper'

class Api::V1::OrdersControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  fixtures :users, :orders, :merchants

  setup do
    @user = users(:elarch)
    sign_in @user
    @order = orders(:elarch_usbkey)
  end

  test "it should create order" do
    assert_difference('Order.count', 1) do
      post :create, order: { url: "http://www.rueducommerce.fr/productA" }, format: :json
    end
    
    assert_response :success
  end

  test "it should show order" do
    get :show, id: @order.uuid, format: :json
    assert_response :success
  end

end

