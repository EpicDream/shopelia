require 'test_helper'

class Api::Flink::InstagramFriendsControllerTest < ActionController::TestCase     
  include Devise::TestHelpers

  setup do
    @flinker = flinkers(:fanny)
    sign_in @flinker
  end
  
  test "get index of instagram friends" do
    betty = InstagramUser.create(flinker_id:flinkers(:betty).id, instagram_id: 601982480, access_token:"token")
    fanny = InstagramUser.create(flinker_id:@flinker.id, instagram_id: 60198248, access_token:"token")
    fanny.friendships << betty
    fanny.stubs(:friends).with(refresh: true).returns([betty])

    get :index, page:1, format: :json
    
    assert_response :success
    assert !json_response["has_next"]
    assert_equal 1, json_response["flinkers"].count
    assert_equal flinkers(:betty).id, json_response["flinkers"].first["id"]
  end

end