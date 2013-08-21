require 'test_helper'

class Api::V1::RegistrationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

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
          phone: "0646403619"
        } ]
      }, format: :json
    end

    assert_response 201
    assert json_response["auth_token"].present?
    assert json_response["user"].present?
    assert_equal 1, json_response["user"]["addresses"].count
  end

  test "it should register a user in visitor mode" do
    User.create(
      :email => "user@gmail.com",
      :visitor => true,
      :developer_id => developers(:prixing).id)
      
    assert_difference('User.count', 0) do
      post :create, user: { 
        email: "user@gmail.com", 
        first_name: "John",
        last_name: "Doe"
      }, format: :json
    end
    
    assert_response 201
    assert json_response["auth_token"].present?
  end

  test "it should fail bad user registration" do
    post :create, user:{}, format: :json
    assert_response 422
  end

end

