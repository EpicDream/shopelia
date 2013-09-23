require 'test_helper'

class CartItemTest < ActiveSupport::TestCase
  
  setup do
    @cart = Cart.create(user_id:users(:elarch).id, kind:Cart::FOLLOW)
    @product_version = product_versions(:usbkey)
    @developer = developers(:prixing)
  end
  
  test "it should create cart item" do
    updated_at = @cart.updated_at
    item = CartItem.new(cart_id:@cart.id, product_version_id:@product_version.id, developer_id:@developer.id, tracker:'toto')

    assert item.save, item.errors.full_messages.join(",")
    assert_equal @product_version.price, item.price
    assert_equal @product_version.price_shipping, item.price_shipping
    assert_equal "toto", item.tracker
    assert @cart.reload.updated_at > updated_at

    assert_equal 2, ActionMailer::Base.deliveries.count
    mail = ActionMailer::Base.deliveries.first
    assert_match /#{@product_version.product.name}/, mail.decoded
    mail = ActionMailer::Base.deliveries.second
    assert_match /#{@product_version.product.name}/, mail.decoded
  end

  test "it shouldn't allow creation of duplicate item" do
    CartItem.create(cart_id:@cart.id, product_version_id:@product_version.id, developer_id:@developer.id)
    item = CartItem.new(cart_id:@cart.id, product_version_id:@product_version.id, developer_id:@developer.id)

    assert !item.save
  end

  test "it should allow same item for different carts" do
    CartItem.create(cart_id:@cart.id, product_version_id:@product_version.id, developer_id:@developer.id)
    item = CartItem.new(cart_id:Cart.create(user_id:users(:elarch).id, kind:Cart::CHECKOUT).id, product_version_id:@product_version.id, developer_id:@developer.id)  

    assert item.save, item.errors.full_messages.join(",")
  end

  test "it should stop monitoring" do
    item = CartItem.create(cart_id:@cart.id, product_version_id:@product_version.id, developer_id:@developer.id)
    item.unsubscribe

    assert !item.monitor?
  end

  test "it should parametrize" do
    item = CartItem.create(cart_id:@cart.id, product_version_id:@product_version.id, developer_id:@developer.id)

    assert_equal item.uuid, item.to_param
  end

  test "it should create cart item from url" do
    item = CartItem.new(
      cart_id:@cart.id, 
      url:"http://www.amazon.fr/gp/product/2081258498",
      developer_id:@developer.id)

    assert item.save
  end

  test "it should fail cart item creation with bad url" do
    item = CartItem.new(
      cart_id:@cart.id, 
      url:"bad url",
      developer_id:@developer.id)

    assert !item.save
    assert_equal I18n.t('app.cart_items.bad_url'), item.errors.full_messages.first
  end
end