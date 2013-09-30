require 'test_helper'

class CartItemsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @user = users(:elarch)
    sign_in @user
  end

  test "it should create new item" do
    assert_difference "CartItem.count" do
      xhr :post, :create, cart_item:{url:"http://www.amazon.fr/gp/product/2081258498/"}

      assert_response :success
    end
  end

  test "it should stop monitoring of item" do
    cart = Cart.create!(user_id:@user.id, kind:Cart::FOLLOW)
    item = CartItem.create!(cart_id:cart.id, product_version_id:product_versions(:usbkey).id, developer_id:developers(:prixing).id)

    assert item.monitor?

    get :unsubscribe, id:item.to_param

    assert_response :success
    assert !item.reload.monitor?
  end
end