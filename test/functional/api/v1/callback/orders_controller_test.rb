require 'test_helper'

class Api::V1::Callback::OrdersControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  fixtures :users, :orders, :merchants, :products, :merchant_accounts, :addresses, :payment_cards

  setup do
    @order = orders(:elarch_rueducommerce)
    @order.update_attribute :state_name, "preparing"
  end

  test "it should callback order" do
    put :update, id:@order.uuid, verb:"message", content:{message:"Test"}, format: :json

    assert_response :success
    assert_equal "Test", @order.reload.message
    assert_equal "preparing", @order.state_name
  end

end

