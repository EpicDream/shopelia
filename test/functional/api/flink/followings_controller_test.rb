require 'test_helper'

class Api::Flink::FollowingsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @flinker = flinkers(:fanny)
    sign_in @flinker
  end

  test "create multiple followings for current flinker" do
    assert_difference "@flinker.reload.followings.count", 2 do
      post :create, followings_ids:[flinkers(:betty).id, flinkers(:boop).id], format: :json
      assert_response :success
    end
  end   

  test "unfollow flinker" do
    follow = FlinkerFollow.create!(flinker_id:@flinker.id, follow_id:flinkers(:betty).id)
    
    assert_difference "@flinker.reload.followings.count", -1 do
      delete :destroy, followings_ids:[flinkers(:betty).id], format: :json
    end    
    
    assert_response :success
    assert !follow.reload.on
  end

  test "followings of current flinker order by username asc" do
    FlinkerFollow.create!(flinker_id:@flinker.id, follow_id:flinkers(:betty).id)
    FlinkerFollow.create!(flinker_id:@flinker.id, follow_id:flinkers(:lilou).id)

    get :index, format: :json
    
    flinkers = json_response["flinkers"]
    
    assert_response :success
    assert_equal 2, flinkers.count
    assert_equal ["Lilou", "bettyusername"], flinkers.map {|f| f["username"]}
  end
  
  test "flinker follows with flinker_id param" do
    boop = flinkers(:boop)
    FlinkerFollow.create!(flinker_id:boop.id, follow_id:flinkers(:betty).id)
    
    get :index, format: :json, flinker_id:boop.id
    
    flinkers = json_response["flinkers"]

    assert_response :success
    assert_equal 1, flinkers.count
    assert_equal flinkers(:betty).id, flinkers.first["id"]
  end
  
  test "touch flinker last_session_open_at timestamp" do
    get :index, format: :json
    
    @flinker.reload
    assert @flinker.last_session_open_at.between?(Time.now - 10.seconds, Time.now)
  end
  
end