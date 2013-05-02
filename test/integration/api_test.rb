# -*- encoding : utf-8 -*-
require 'test_helper'

class ApiTest < ActionDispatch::IntegrationTest
  
  test "user account creation and ordering process" do
    allow_remote_api_calls
    VCR.use_cassette('integration') do

      user = { 
        email: "test@shopelia.fr",
        first_name: "John",
        last_name: "Doe",
        addresses_attributes: [ {
          address1: "21 rue d'Aboukir",
          zip: "75002",
          city: "Paris",
          phones_attributes: [ {
            number: "0140404040",
            line_type: Phone::LAND 
          } ] 
        } ],
        phones_attributes: [ {
          number: "0640404040",
          line_type: Phone::MOBILE
        } ]
      }

      post "/api/users", user:user, format: :json
      assert json_response["user"]
      assert json_response["auth_token"]
      
      user = User.find_by_id(json_response["user"]["id"])
      auth_token = json_response["auth_token"]

      post "/api/orders", auth_token:auth_token, order: { urls: ["http://www.amazon.fr/La-Belle-Clochard-Peggy-Lee/dp/B0065HDMNO"] }, format: :json
      assert json_response["order"]
    end
  end

end

