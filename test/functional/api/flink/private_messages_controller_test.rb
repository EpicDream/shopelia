require 'test_helper'

class Api::Flink::PrivateMessagesControllerTest < ActionController::TestCase     
  include Devise::TestHelpers

  setup do
    @flinker = flinkers(:betty)
    @target = flinkers(:fanny)
    sign_in @flinker
  end

  test "create private message" do
    post :create, content:"Hello", target_id:@target.id, look_uuid:"12u3", format: :json

    assert_response :success
    
    message = PrivateMessage.last
    
    assert_equal "Hello", message.content
    assert_equal @flinker, message.flinker
    assert_equal @target, message.target
    assert_equal looks(:thaiti), message.look
  end

end