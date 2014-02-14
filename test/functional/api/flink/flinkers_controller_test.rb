require 'test_helper'

class Api::Flink::FlinkersControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    sign_in flinkers(:elarch)
  end

  test "it should get publishing flinkers" do
    get :index, format: :json
    assert_response :success
    
    assert_equal 4, json_response["flinkers"].count
  end
  
  test "get flinkers with coutry filter" do
    get :index, page:1, country_iso:'fr', format: :json
    assert_response :success
    
    assert_equal 2, json_response["flinkers"].count
  end
  
  test "search flinkers by username (this must skip publisher filter)" do
    get :index, page:1, username:"fann", format: :json
    assert_response :success
    
    assert_equal 1, json_response["flinkers"].count
    assert_equal "fanny.louvel@wanadoo.fr", json_response["flinkers"].first["email"]
    
    get :index, page:1, username:"zeta", format: :json

    assert_response :success
    assert_equal 0, json_response["flinkers"].count
  end
  
end
