require 'test_helper'

class Api::V1::Limonetik::OrdersControllerTest < ActionController::TestCase

  setup do
    @order = orders(:elarch_rueducommerce)
  end

  test "it should callback order" do
    put :update, id:@order.uuid, status:"success", amount:150, limonetik_order_id:123, format: :json
    assert_response :success
  end
  
  test "it should fail if order doesn't exist" do
    put :update, id:"bad", status:"success", amount:150, limonetik_order_id:123, format: :json
    assert_response :not_found
  end

  test "it should fail if missing parameters" do
    put :update, id:@order.uuid, format: :json
    assert_response 422
  end

end

