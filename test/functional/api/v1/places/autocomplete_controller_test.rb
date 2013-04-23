require 'test_helper'

class Api::V1::Places::AutocompleteControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "it should autocomplete location" do
    VCR.use_cassette('places_api') do  
      get :index, query: "21 rue Abou", lat:48.82, lng:2.24, format: :json

      assert_response :success
      assert_equal 5, json_response.size     
    end
  end

end

