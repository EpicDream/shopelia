require 'test_helper'

class Api::Flink::FollowsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @flinker = flinkers(:elarch)
    sign_in @flinker
    Sidekiq::Testing.fake!
  end

  test "it should create multiple follows" do
    assert_difference "FlinkerFollow.count", 2 do
      post :create, follows:[flinkers(:betty).id, flinkers(:boop).id], format: :json
      assert_response :success
    end
  end   

  test "it should destroy follow" do
    FlinkerFollow.create!(flinker_id:@flinker.id, follow_id:flinkers(:betty).id)
    
    assert_difference "FlinkerFollow.count", -1 do
      post :destroy, id:flinkers(:betty).id, format: :json
      assert_response :success
    end    
  end

  test "it should sent all following id" do
    FlinkerFollow.create!(flinker_id:@flinker.id, follow_id:flinkers(:betty).id)

    get :index, format: :json
    assert_response :success

    assert_equal 1, json_response.count
  end
end