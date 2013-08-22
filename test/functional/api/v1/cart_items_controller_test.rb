require 'test_helper'

class Api::V1::CartItemsControllerTest < ActionController::TestCase

  test "it should add new item for unknown email" do
    assert_difference(["Cart.count", "CartItem.count", "User.count"], 1) do
      post :create, product_version_id:product_versions(:usbkey).id, email:"toto@gmail.com"
      assert_response :success
    end
  end

  test "it should add new item for known email" do
    assert_difference(["Cart.count", "CartItem.count"], 1) do
      post :create, product_version_id:product_versions(:usbkey).id, email:users(:elarch).email
      assert_response :success
    end
  end

  test "it shouldn't add twice the same item in a list" do
    post :create, product_version_id:product_versions(:usbkey).id, email:users(:elarch).email
    assert_difference(["Cart.count", "CartItem.count"], 0) do
      post :create, product_version_id:product_versions(:usbkey).id, email:users(:elarch).email
      assert_response :success
    end    
  end

  test "it should reset monitor to true if add an item not monitored" do
    post :create, product_version_id:product_versions(:usbkey).id, email:users(:elarch).email
    item = CartItem.last
    item.update_attribute :monitor, false
    post :create, product_version_id:product_versions(:usbkey).id, email:users(:elarch).email

    assert item.reload.monitor
  end
end

