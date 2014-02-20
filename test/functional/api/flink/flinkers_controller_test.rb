require 'test_helper'

class Api::Flink::FlinkersControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    sign_in flinkers(:elarch)
  end

  test "get publishing flinkers with looks" do
    get :index, format: :json
   
    assert_response :success
    assert_equal 4, json_response["flinkers"].count
  end
  
  test "get specific flinkers on provided ids" do
    betty, fanny = flinkers(:betty), flinkers(:fanny)
    
    get :index, format: :json, ids:[betty.id, fanny.id]

    assert_response :success
    
    assert_equal 2, json_response["flinkers"].count
    assert_equal [betty.id, fanny.id].to_set, json_response["flinkers"].map{|f| f["id"]}.to_set
  end
  
end
