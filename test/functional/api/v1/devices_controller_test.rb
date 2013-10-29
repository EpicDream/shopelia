require 'test_helper'

class Api::V1::DevicesControllerTest < ActionController::TestCase

  setup do
    @device = devices(:mobile)
  end

  test "it should update device" do
    put :update, id:@device.uuid, device:{push_token:"token", referrer:"http://www.shopelia.com"}, format: :json
    assert_response :success
    
    assert_equal "token", @device.reload.push_token
    assert_equal "http://www.shopelia.com", @device.referrer
  end

  test "it should also create device when updating (UUID is generated client side)" do
    assert_difference "Device.count" do
      put :update, id:"newdeviceuuid", device:{push_token:"token"}, format: :json
      assert_response :success
    end
  end
end