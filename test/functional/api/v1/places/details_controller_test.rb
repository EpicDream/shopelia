require 'test_helper'

class Api::V1::Places::DetailsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "it should get details for place reference" do
    VCR.use_cassette('places_api') do  
      get :show, id: "ClRNAAAAu2vgwlaOOP9j92SUZSmS6c3XQppD_H3-g-LForQzhQAihTD0uTNT234nHwpnaVeWvCdntvOmrwouNIcBQwO4cOPR3bmdimEO0pP-9DwKQFoSEPa_CqCJIjc3H-w5hoxAQ60aFBJxKAF7cHWMdYe2A4bzJmCScypn", format: :json

      assert_response :success
      assert_equal 4, json_response.size
    end
  end

end

