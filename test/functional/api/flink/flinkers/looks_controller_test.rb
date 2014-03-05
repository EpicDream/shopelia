require 'test_helper'

class Api::Flink::Flinkers::LooksControllerTest < ActionController::TestCase     
  include Devise::TestHelpers

  setup do
    @flinker = flinkers(:fanny)
    @publishers = [flinkers(:betty), flinkers(:lilou)]
    populate_looks_for @publishers
    sign_in @flinker
  end
  
  test "looks of given flinkers ordered by flink_published_at" do
    
    get :index, format: :json, flinkers_ids:@publishers.map(&:id), per_page:100
    
    assert_response :success
    
    looks = json_response["looks"]
    assert_equal 20, looks.count
    assert looks.first["flink_published_at"] > looks.last["flink_published_at"]
  end
  
  test "looks of given flinkers published between" do
    options = { format: :json, flinkers_ids:@publishers.map(&:id), flink_published_after:2.days.ago }
    get :index, options
    
    assert_response :success
    
    looks = json_response["looks"]
    assert_equal 4, looks.count
    assert looks.first["flink_published_at"] >= looks.last["flink_published_at"]
  end
  

end