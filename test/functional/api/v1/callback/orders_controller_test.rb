require 'test_helper'

class Api::V1::Callback::OrdersControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  fixtures :users, :orders, :merchants, :products, :merchant_accounts, :addresses

  setup do
    @order = orders(:elarch_rueducommerce)
  end

  test "it should callback order" do
    put :update, id:@order.uuid, verb:"message", content:{status:"Test"}, format: :json

    assert_response :success
    assert_equal "Test", @order.reload.message
    assert_equal "pending", @order.state_name
  end

end

