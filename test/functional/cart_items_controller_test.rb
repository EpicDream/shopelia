require 'test_helper'

class CartItemsControllerTest < ActionController::TestCase

  setup do
    @cart = Cart.create(user_id:users(:elarch).id)
    @product_version = product_versions(:usbkey)
    @item = CartItem.create!(cart_id:@cart.id, product_version_id:@product_version.id, developer_id:developers(:prixing).id)
  end

  test "it should stop monitoring of item" do
    assert @item.monitor?

    get :unsubscribe, id:@item.to_param

    assert_response :success
    assert !@item.reload.monitor?
  end
end

