require 'test_helper'

class Api::Flink::Refresh::LikesControllerTest < ActionController::TestCase     
  include Devise::TestHelpers
  
  setup do
    @flinker = flinkers(:boop)
    sign_in @flinker
  end
  
  test "get liked looks and unliked looks of current flinker" do
    FlinkerLike.destroy_all
    likes = like(@flinker, Look.all) #4 likes
    
    likes[0..2].each_with_index { |like, i| like.updated_at = Time.now - i.hours; like.save! }
    
    unlike = likes[3]
    assert unlike.update_attributes(on:false)

    get :index, format: :json

    assert_response :success
    
    liked_looks = json_response["likes"]
    unliked_looks = json_response["unlikes"]

    assert_equal likes[2].updated_at.to_i, liked_looks["min_timestamp"]
    assert_equal likes[0].updated_at.to_i, liked_looks["max_timestamp"]
    assert_equal 3, liked_looks["looks"].count
    assert_equal 1, unliked_looks["looks"].count
  end
  
  test "get liked looks and unliked looks of current flinker updated after date" do
    after = Time.now - 1.day
    likes = FlinkerLike.where(flinker_id:@flinker.id)
    likes.update_all(updated_at: after - 1.day)
    unlike = likes.last
    assert unlike.update_attributes(on:false, updated_at: after + 1.hour)

    get :index, updated_after: after.to_i, format: :json

    assert_response :success
    
    liked_looks = json_response["likes"]
    unliked_looks = json_response["unlikes"]
    
    assert_equal 0, liked_looks["looks"].count
    assert_equal 1, unliked_looks["looks"].count
  end
  
  
end