require 'test_helper'

class Api::V1::Phones::LookupControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "it should lookup number" do
    VCR.use_cassette('scrapers/reverse_directory') do  
      get :index, phone_id: "0959497434", format: :json

      assert_response :success
      assert_equal 5, json_response.size
    end
  end

end

