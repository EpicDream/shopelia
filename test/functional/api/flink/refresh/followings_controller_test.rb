require 'test_helper'

class Api::Flink::Refresh::FollowingsControllerTest < ActionController::TestCase     
  include Devise::TestHelpers
  
  setup do
    @flinker = flinkers(:boop)
    sign_in @flinker
  end
  
  test "get followings and unfollowings flinkers of current flinker" do
    f1 = follow flinkers(:fanny)
    f2 = follow flinkers(:lilou)
    f3 = follow flinkers(:betty)
    assert f1.update_attributes(updated_at: Time.now - 1.hour)
    assert f3.update_attributes(on:false)

    get :index, format: :json

    assert_response :success

    follows = json_response["followings"]
    unfollows = json_response["unfollowings"]
    
    assert_equal f1.updated_at.to_i, follows["min_timestamp"]
    assert_equal f2.updated_at.to_i, follows["max_timestamp"]
    assert_equal 2, follows["flinkers"].count
    assert_equal 1, unfollows["flinkers"].count
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
    
    assert_equal 0, follows["flinkers"].count
    assert_equal 1, unfollows["flinkers"].count
  end
  
end