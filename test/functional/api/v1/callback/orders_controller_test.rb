require 'test_helper'

class Api::V1::Callback::OrdersControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  fixtures :users, :orders, :merchants, :products

  setup do
    @order = orders(:elarch_usbkey)
    @data = { :verb => "message", :content => "Test", :session => { :state => "pending" } }
  end

  test "it should callback order" do
    put :update, id:@order.uuid, data:@data, format: :json

    assert_response :success
    assert_equal "Test", @order.reload.message
    assert_equal "pending", @order.state_name
  end

end

