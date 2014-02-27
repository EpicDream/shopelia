require 'test_helper'

class Api::Flink::Likes::LooksControllerTest < ActionController::TestCase     
  include Devise::TestHelpers

  setup do
    @flinker = flinkers(:fanny)
    sign_in @flinker
  end

  test "looks liked of current flinker" do
    FlinkerLike.create!(flinker_id:@flinker.id, resource_type:FlinkerLike::LOOK, resource_id:Look.first.id)

    get :index, format: :json
    
    assert_response :success
    assert_equal 1, json_response["looks"].count
    assert_equal Look.first.uuid, json_response["looks"].first["uuid"]
  end
  
  test "looks liked of flinker with given id" do
    flinker = flinkers(:lilou)
    FlinkerLike.destroy_all
    FlinkerLike.create!(flinker_id:flinker.id, resource_type:FlinkerLike::LOOK, resource_id:Look.first.id)
    
    get :index, format: :json, flinker_id:flinker.id
    
    assert_response :success
    assert_equal 1, json_response["looks"].count
    assert_equal Look.first.uuid, json_response["looks"].first["uuid"]
  end

end