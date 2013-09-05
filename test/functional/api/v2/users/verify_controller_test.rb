require 'test_helper'

class Api::V2::Users::VerifyControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @user = users(:elarch)
    sign_in @user
  end

  test "it should verify user" do
    post :create, pincode:"1234", format: :json
    assert_response :success
    
    assert json_response['user'].present?
  end

  test "it should verify user with password" do
    post :create, password:"tototo", format: :json
    assert_response :success
  end

  test "it should verify user with cc info" do
    post :create, cc_num:"0154", cc_month:"02", cc_year:"15", format: :json
    assert_response :success
  end

  test "it should fail user verification" do
    post :create, pincode:"4567", format: :json
    assert_response :not_found
  end
  
  test "it should send 503 with delay after 3 failures, even with correct pincode" do
    post :create, pincode:"4567", format: :json
    assert_response :not_found

    post :create, pincode:"4567", format: :json
    assert_response :not_found

    post :create, pincode:"4567", format: :json
    assert_response :not_found
    
    post :create, pincode:"1234", format: :json
    assert_response 503
    assert_equal [59,60].include?(json_response["delay"])
  end

end

