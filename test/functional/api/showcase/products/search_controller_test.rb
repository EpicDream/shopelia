require 'test_helper'

class Api::Showcase::Products::SearchControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  test "it should answer to ean search" do
    get :index, ean:"9782749910116", format: :json
  
    assert_response :success
    assert json_response["name"].present?
  end
end