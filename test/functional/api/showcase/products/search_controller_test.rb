require 'test_helper'

class Api::Showcase::Products::SearchControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  test "it should answer to ean search" do
    assert_difference "Event.count", 2 do
      get :index, ean:"9782749910116", visitor:"uuid", format: :json
    
      assert_response :success
      assert json_response["name"].present?
    end
  end

  test "it should fail answer if no visitor param" do
    get :index, ean:"9782749910116", format: :json
    
    assert_response :bad_request
  end
end