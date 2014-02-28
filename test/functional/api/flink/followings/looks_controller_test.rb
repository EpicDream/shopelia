require 'test_helper'

class Api::Flink::Followings::LooksControllerTest < ActionController::TestCase     
  include Devise::TestHelpers

  setup do
    @flinker = flinkers(:fanny)
    @publishers = [flinkers(:betty), flinkers(:lilou)]
    populate_looks_for @publishers
    sign_in @flinker
  end

  test "looks of current flinker followings ordered by flink_published_at desc" do
    follow flinkers(:betty)
    follow flinkers(:lilou)
    
    get :index, format: :json, per_page:100
    
    assert_response :success
    
    looks = json_response["looks"]
    assert_equal 20, looks.count
    assert looks.first["flink_published_at"] > looks.last["flink_published_at"]
  end
  
  test "looks of current flinker followings only" do
    follow flinkers(:betty)
    
    get :index, format: :json, per_page:100
    
    assert_response :success
    assert_equal 10, json_response["looks"].count
  end
  
  test "looks of current flinker followings published between dates" do
    follow flinkers(:betty)
    after = 3.days.ago.to_i
    before = 1.day.ago.to_i
     
    get :index, format: :json, per_page:20, flink_published_after:after, flink_published_before:before
    
    assert_response :success
    assert_equal 2, json_response["looks"].count
  end
  
end