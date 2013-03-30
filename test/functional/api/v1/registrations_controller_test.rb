require 'test_helper'

class Api::V1::RegistrationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  fixtures :countries, :psps

  test "it should register new user" do
    assert_difference('User.count') do
      post :create, user: { 
        email: "user@gmail.com", 
        password: "password", 
        password_confirmation: "password",
        first_name: "John",
        last_name: "Doe",
        civility: User::CIVILITY_MR,
        nationality_id: countries(:france).id,
        birthdate: '1973-01-01' }, format: :json
    end

    assert_response 201
  end

  test "it should fail bad user registration" do
    post :create, user:{}, format: :json
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
          birthdate: '1973-09-30' }, format: :json
      end
      assert_response 422
    end
  end

end

