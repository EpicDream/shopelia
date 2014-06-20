require 'test_helper'

class Api::Flink::TwitterFriendsControllerTest < ActionController::TestCase     
  include Devise::TestHelpers

  setup do
    @flinker = flinkers(:fanny)
    sign_in @flinker
  end
  
  test "get index of twitter friends" do
    betty = TwitterUser.create(flinker_id:flinkers(:betty).id, twitter_id: "147937366", access_token:"token")
    fanny = TwitterUser.create(flinker_id:@flinker.id, twitter_id: "2227040976", access_token:"token")
    fanny.friendships << betty
    fanny.stubs(:friends).with(refresh: true).returns([betty])

    get :index, page:1, format: :json
    
    assert_response :success
    assert !json_response["has_next"]
    assert_equal 1, json_response["flinkers"].count
    assert_equal flinkers(:betty).id, json_response["flinkers"].first["id"]
  end

end