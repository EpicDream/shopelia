require 'test_helper'

class Api::Flink::Refresh::FollowingsControllerTest < ActionController::TestCase     
  include Devise::TestHelpers
  
  setup do
    @flinker = flinkers(:boop)
    sign_in @flinker
  end
  
  test "get followings and unfollowings flinkers of current flinker" do
    follow flinkers(:fanny)
    following = follow flinkers(:betty)
    
    assert following.update_attributes(on:false)

    get :index, format: :json

    assert_response :success

    follows = json_response["followings"]
    unfollows = json_response["unfollowings"]
    
    assert_equal 1, follows.count
    assert_equal 1, unfollows.count
  end
  
  test "get followings and unfollowings flinkers of current flinker updated after date" do
    after = Time.now - 1.day
    follow flinkers(:fanny)
    following = follow flinkers(:betty)
    FlinkerFollow.update_all(updated_at: after - 1.day)
    assert following.update_attributes(on:false, updated_at: after + 1.hour)

    get :index, updated_after: after.to_i, format: :json

    assert_response :success
    
    follows = json_response["followings"]
    unfollows = json_response["unfollowings"]
    
    assert_equal 0, follows.count
    assert_equal 1, unfollows.count
  end
  
end