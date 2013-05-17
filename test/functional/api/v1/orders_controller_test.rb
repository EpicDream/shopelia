require 'test_helper'

class Api::V1::OrdersControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  fixtures :users, :orders, :merchants, :order_items, :merchant_accounts, :addresses, :payment_cards

  setup do
    @user = users(:elarch)
    sign_in @user
    @order = orders(:elarch_rueducommerce)
    @card = payment_cards(:elarch_hsbc)
  end

  test "it should create order" do
    assert_difference('Order.count', 1) do
      post :create, order: { expected_price_total:100, payment_card_id:@card.id, urls: ["http://www.rueducommerce.fr/productA"] }, format: :json
    end
    
    assert_response :success
    assert_equal "processing", Order.last.state_name
  end

  test "it should show order" do
    get :show, id: @order.uuid, format: :json
    assert_response :success
  end

end

