require 'test_helper'

class Api::V1::CartItemsControllerTest < ActionController::TestCase

  test "it should add new item for unknown email" do
    assert_difference(["Cart.count", "CartItem.count", "User.count"], 1) do
      post :create, product_version_id:product_versions(:usbkey).id, email:"toto@gmail.com"
      assert_response :success
    end
  end

  test "it should add new item for knownn email" do
    assert_difference(["Cart.count", "CartItem.count"], 1) do
      post :create, product_version_id:product_versions(:usbkey).id, email:users(:elarch).email
      assert_response :success
    end
  end

end

