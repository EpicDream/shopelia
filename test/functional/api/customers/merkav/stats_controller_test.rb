require 'test_helper'

class Api::Customers::Merkav::StatsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    ENV["API_KEY"] = developers(:merkav).api_key
  end

  test "it should send stats" do
    get :index, format: :json
    assert_response :success
  end
end