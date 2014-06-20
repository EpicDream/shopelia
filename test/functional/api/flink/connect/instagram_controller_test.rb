require 'test_helper'

class Api::Flink::Connect::InstagramControllerTest < ActionController::TestCase     
  include Devise::TestHelpers
  
  setup do
    @flinker = flinkers(:fanny)
    sign_in @flinker
  end
  
  test "create instagram connection" do
    InstagramUser.expects(:init).with(@flinker, "token").returns(stub)
    
    post :create, token:"token", format: :json
    
    assert_response :success
  end
end