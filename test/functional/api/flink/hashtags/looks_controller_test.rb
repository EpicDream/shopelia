require 'test_helper'

class Api::Flink::Hashtags::LooksControllerTest < ActionController::TestCase     
  include Devise::TestHelpers
  
  setup do
    @flinker = flinkers(:fanny)
    sign_in @flinker
    @hashtags = ["mode", "fashion", "tendance"].map { |name| Hashtag.create(name:name) }
    looks(:agadir).hashtags << @hashtags.first
    looks(:quimper).hashtags << @hashtags
  end
  
  test "get looks with hashtags matching hashtag keyword" do
    
    get :index, format: :json, hashtag:"tendance"
    
    assert_response :success
    
    looks = json_response["looks"]

    assert_equal 1, looks.count
    assert_equal looks(:quimper).flinker.id, looks.first["flinker"]["id"]
  end
  
  test "get looks with hashtags matching hashtag keyword, matching several looks" do
    
    get :index, format: :json, hashtag:"mode"
    
    assert_response :success
    
    looks = json_response["looks"]

    assert_equal 2, looks.count
    assert_equal [408576487, 520688968].to_set, looks.map { |look| look["flinker"]["id"] }.to_set
  end
  
end