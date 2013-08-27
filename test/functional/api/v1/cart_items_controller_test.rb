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
    assert_equal users(:elarch).id, Cart.first.user_id
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

  test "it should set device with known user after registration" do
    device = devices(:web)
    @request.cookies['visitor'] = device.uuid
    post :create, product_version_id:product_versions(:usbkey).id, email:users(:elarch).email

    assert_not_nil device.reload.user_id
  end

  test "it should set device with unknown user after registration" do
    device = devices(:web)
    @request.cookies['visitor'] = device.uuid
    post :create, product_version_id:product_versions(:usbkey).id, email:"toto@gmail.com"

    assert_not_nil device.reload.user_id
  end
end

