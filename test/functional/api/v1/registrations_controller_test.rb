require 'test_helper'

class Api::V1::RegistrationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  fixtures :countries, :psps

  test "it should register new user" do
    assert_difference(['User.count','Address.count']) do
      post :create, user: { 
        email: "user@gmail.com", 
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
      }.to_json, format: :json
    end

    assert_response 201
    assert json_response["auth_token"].present?
    assert json_response["user"].present?
    assert_equal 1, json_response["user"]["addresses"].count
  end

  test "it should fail bad user registration" do
    post :create, user:{}.to_json, format: :json
    assert_response 422
  end
  
  test "it should fail user registration if Leetchi API fails" do
    allow_remote_api_calls
    VCR.use_cassette('user_fail') do
      assert_difference('User.count', 0) do
        post :create, user: { 
          email: "willfail@gmail.com", 
          password: "tototo", 
          password_confirmation: "tototo",
          first_name: "Joe",
          last_name: "Fail",
          civility: User::CIVILITY_MR,
          nationality_id: countries(:france).id,
          birthdate: '1973-09-30' }.to_json, format: :json
      end
      assert_response 422
    end
  end

end

