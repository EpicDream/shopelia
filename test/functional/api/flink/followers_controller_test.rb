require 'test_helper'

class Api::Flink::FollowersControllerTest < ActionController::TestCase     
  include Devise::TestHelpers

  setup do
    @fanny = flinkers(:fanny)
    sign_in @fanny
  end
  
  test "followers of current flinker" do
    boop, lilou = flinkers(:boop), flinkers(:lilou)
    [boop, lilou].each do |flinker|
      FlinkerFollow.create!(flinker_id:flinker.id, follow_id:@fanny.id)
    end

    get :index, format: :json
    
    flinkers = json_response["flinkers"]
    assert_response :success
    assert_equal 2, flinkers.count
    assert_equal [boop.id, lilou.id].to_set, flinkers.map { |f| f["id"] }.to_set
  end
  
  test "followers of any flinker" do
    [flinkers(:boop), @fanny].each do |flinker|
      FlinkerFollow.create!(flinker_id:flinker.id, follow_id:flinkers(:lilou).id)
    end

    get :index, format: :json, flinker_id:flinkers(:lilou).id
    
    flinkers = json_response["flinkers"]
    assert_response :success
    assert_equal 2, flinkers.count
    assert_equal [flinkers(:boop).id, @fanny.id].to_set, flinkers.map { |f| f["id"] }.to_set
  end
  
end