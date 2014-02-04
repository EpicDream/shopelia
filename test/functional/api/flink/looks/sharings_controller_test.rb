require 'test_helper'

class Api::Flink::Looks::SharingsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @flinker = flinkers(:lilou)
    @look = looks(:agadir)
  end
  
  test "parameters must contain social network name, flinker id, and look id" do
    sign_in @flinker
    
    post :create, look_id:1
    
    assert_response :error
  end
  
  test "create sharing" do
    sign_in @flinker
    
    LookSharing.any_instance.expects(:save).returns(:true)
    post :create, look_id:@look.uuid, flinker_id:@flinker.id, social_network:"twitter", format: :json

    assert_response :success
  end
end
