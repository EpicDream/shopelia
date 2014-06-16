require 'test_helper'

class Api::Flink::Refresh::LooksControllerTest < ActionController::TestCase     
  include Devise::TestHelpers
  
  setup do
    @flinker = flinkers(:betty)
    sign_in @flinker
  end
  
  test "get light informations about looks for refresh UI" do
    get :index, uuids:["uuid", "12u3"], format: :json

    looks = json_response["looks"]
    look = looks.first
    
    assert_response :success
    assert_equal 2, looks.count
    assert_equal ["uuid", "liked_by_friends", "highlighted_hashtags", "comments_count", "likes_count"], look.keys
  end
  
end