require 'test_helper'

class Api::Flink::ActivitiesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @fanny = flinkers(:fanny)
    sign_in @fanny
    Comment.any_instance.stubs(:can_be_posted_on_blog?).returns(false)
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
    assert_equal Activity.last.id, activity["id"]
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
    Sidekiq::Testing.inline! do
      follow(flinkers(:boop), @fanny)
    
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
  end
  
  test "get likes activities related to current flinker" do
    follow(flinkers(:boop), @fanny)
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
  
  test "get facebook friend sign up activity related to current flinker" do
    FlinkerAuthentication.create!(provider:"facebook", uid:"9090909", flinker_id:flinkers(:boop).id)
    
    get :index, format: :json
    
    activity = json_response["activities"].first

    assert_response :success
    assert_equal 1, json_response["activities"].count
    assert_equal nil, activity["comment_id"]
    assert_equal nil, activity["look_uuid"]
    assert_equal "FacebookFriendSignedUpActivity", activity["type"]
    assert_equal flinkers(:boop).id, activity["flinker_id"]
  end
  
  test "get comment timeline activities related to current flinker" do
    Comment.create!(body:"Cool!", look_id:looks(:agadir).id, flinker_id:flinkers(:fanny).id)
    comment = Comment.create!(body:"Cool!", look_id:looks(:agadir).id, flinker_id:flinkers(:nana).id) 
    
    get :index, format: :json
    
    activity = json_response["activities"].first

    assert_response :success
    assert_equal 1, json_response["activities"].count
    assert_equal comment.id, activity["comment_id"]
    assert_equal looks(:agadir).uuid, activity["look_uuid"]
    assert_equal "CommentTimelineActivity", activity["type"]
    assert_equal flinkers(:nana).id, activity["flinker_id"]
  end
  
  test "get share activities related to current flinker" do
    look = looks(:agadir)
    flinker = flinkers(:lilou)
    follow(flinker, flinkers(:fanny))
    LookSharing.on("twitter").for(look_id:look.id, flinker_id:flinker.id)
    LookSharing.on("facebook").for(look_id:look.id, flinker_id:flinker.id)
    
    get :index, format: :json
    
    activities = json_response["activities"]
    activity = activities.first

    assert_response :success
    assert_equal 2, activities.count
    assert_equal ["twitter","facebook"].to_set, activities.map{ |act| act["social_network"] }.to_set
    assert_equal looks(:agadir).uuid, activity["look_uuid"]
    assert_equal "ShareActivity", activity["type"]
    assert_equal flinker.id, activity["flinker_id"]
  end
  
  test "get all different activities related to current flinker" do
    Sidekiq::Testing.inline! do

      follow(flinkers(:boop), @fanny)
    
      MentionActivity.create!(comments(:agadir))
      FlinkerFollow.create(flinker_id:flinkers(:boop).id, follow_id:@fanny.id)
      CommentActivity.create!(comments(:agadir))
      LikeActivity.create!(flinker_likes(:boop_like))
      FlinkerAuthentication.create!(provider:"facebook", uid:"9090909", flinker_id:flinkers(:boop).id)
      Comment.create!(body:"Cool!", look_id:looks(:agadir).id, flinker_id:flinkers(:fanny).id) #fanny comment
      Comment.create!(body:"Cool!", look_id:looks(:agadir).id, flinker_id:flinkers(:nana).id) 
      LookSharing.on("twitter").for(look_id:looks(:agadir).id, flinker_id:flinkers(:boop).id)
      LookSharing.on("facebook").for(look_id:looks(:agadir).id, flinker_id:flinkers(:boop).id)

      get :index, format: :json
    
      activities = json_response["activities"]

      assert_response :success
      assert_equal 7, activities.map{ |activity| activity["type"] }.uniq.count
    end
  end
end
