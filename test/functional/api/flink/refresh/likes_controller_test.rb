require 'test_helper'

class Api::Flink::Refresh::LikesControllerTest < ActionController::TestCase     
  include Devise::TestHelpers
  
  setup do
    @flinker = flinkers(:boop)
    sign_in @flinker
  end
  
  test "get liked looks and unliked looks of current flinker" do
    likes = FlinkerLike.where(flinker_id:@flinker.id)
    unlike = likes.last
    assert unlike.update_attributes(on:false)

    get :index, format: :json

    assert_response :success
    
    liked_looks = json_response["liked_looks"]
    unliked_looks = json_response["unliked_looks"]
    
    assert_equal 1, liked_looks.count
    assert_equal 1, unliked_looks.count
  end
  
  test "get liked looks and unliked looks of current flinker updated after date" do
    after = Time.now - 1.day
    likes = FlinkerLike.where(flinker_id:@flinker.id)
    likes.update_all(updated_at: after - 1.day)
    unlike = likes.last
    assert unlike.update_attributes(on:false, updated_at: after + 1.hour)

    get :index, updated_after: after.to_i, format: :json

    assert_response :success
    
    liked_looks = json_response["liked_looks"]
    unliked_looks = json_response["unliked_looks"]
    
    assert_equal 0, liked_looks.count
    assert_equal 1, unliked_looks.count
  end
  
  
end