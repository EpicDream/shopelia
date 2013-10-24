require 'test_helper'

class Api::V1::DevicesControllerTest < ActionController::TestCase

  setup do
    @device = devices(:mobile)
  end

  test "it should update device" do
    put :update, id:@device.uuid, device:{push_token:"token"}, format: :json
    assert_response :success
    
    assert_equal "token", @device.reload.push_token
  end
end