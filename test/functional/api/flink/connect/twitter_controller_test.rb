require 'test_helper'

class Api::Flink::Connect::TwitterControllerTest < ActionController::TestCase     
  include Devise::TestHelpers
  
  setup do
    @flinker = flinkers(:fanny)
    sign_in @flinker
  end
  
  test "create twitter connection" do
    TwitterUser.expects(:init).with(@flinker, "token", "token-secret").returns(stub)
    
    post :create, token:"token", token_secret:"token-secret", format: :json
    
    assert_response :success
  end
end