require 'test_helper'

class Api::Flink::ActivitiesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @fanny = flinkers(:fanny)
    sign_in @fanny
  end
  
  test "get mentions activities related to current flinker" do
    MentionActivity.create!(comments(:agadir))
    
    get :index, format: :json
    
    activity = json_response["activities"].first

    assert_response :success
    assert_equal 1, json_response["activities"].count
    assert_equal comments(:agadir).id, activity["comment_id"]
    assert_equal comments(:agadir).look.uuid, activity["look_uuid"]
    assert_equal "MentionActivity", activity["type"]
    assert_equal flinkers(:boop).id, activity["flinker_id"]
  end
  
  test "get follow activities related to current flinker" do
    FlinkerFollow.create(flinker_id:flinkers(:boop).id, follow_id:@fanny.id)
    
    get :index, format: :json
    
    activity = json_response["activities"].first

    assert_response :success
    assert_equal 1, json_response["activities"].count
    assert_equal nil, activity["comment_id"]
    assert_equal nil, activity["look_uuid"]
    assert_equal "FollowActivity", activity["type"]
    assert_equal flinkers(:boop).id, activity["flinker_id"]
  end
  
  test "get comments activities related to current flinker" do
    assert flinkers(:boop).friends.include?(@fanny)
    
    CommentActivity.create!(comments(:agadir)) #boop comment
    
    get :index, format: :json
    
    activity = json_response["activities"].first

    assert_response :success
    assert_equal 1, json_response["activities"].count
    assert_equal comments(:agadir).id, activity["comment_id"]
    assert_equal comments(:agadir).look.uuid, activity["look_uuid"]
    assert_equal "CommentActivity", activity["type"]
    assert_equal flinkers(:boop).id, activity["flinker_id"]
  end
  
  test "get likes activities related to current flinker" do
    assert flinkers(:boop).friends.include?(@fanny)
    LikeActivity.create!(flinker_likes(:boop_like))
    
    get :index, format: :json
    
    activity = json_response["activities"].first

    assert_response :success
    assert_equal 1, json_response["activities"].count
    assert_equal nil, activity["comment_id"]
    assert_equal flinker_likes(:boop_like).look.uuid, activity["look_uuid"]
    assert_equal "LikeActivity", activity["type"]
    assert_equal flinkers(:boop).id, activity["flinker_id"]
  end
  
  test "get all different activities related to current flinker" do
    MentionActivity.create!(comments(:agadir))
    FlinkerFollow.create(flinker_id:flinkers(:boop).id, follow_id:@fanny.id)
    CommentActivity.create!(comments(:agadir))
    LikeActivity.create!(flinker_likes(:boop_like))
    
    get :index, format: :json
    
    activities = json_response["activities"]

    assert_response :success
    assert_equal 4, activities.count
  end
end
