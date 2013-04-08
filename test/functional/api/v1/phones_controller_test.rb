require 'test_helper'

class Api::V1::PhonesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  fixtures :users, :phones

  setup do
    @user = users(:elarch)
    sign_in @user
    @phone = phones(:phone_neuilly)
  end

  test "it should create phone" do
    assert_difference('Phone.count', 1) do
      post :create, phone: {
        number: "0640381383",
        line_type: Phone::MOBILE }.to_json, format: :json
    end
    
    assert_response :success
  end

  test "it should show phone" do
    get :show, id: @phone, format: :json
    assert_response :success
  end

  test "it should get all phones for user" do
    get :index, format: :json
    assert_response :success
    
    assert json_response.kind_of?(Array), "Should get an array of phones"
    assert_equal 2, json_response.count
  end

  test "it should update phone" do
    put :update, id: @phone, phone: { number: "0646403610" }.to_json, format: :json
    assert_response 204
  end

  test "it should destroy phone" do
    assert_difference('Phone.count', -1) do
      delete :destroy, id: @phone, format: :json
    end

    assert_response 204
  end
  
  test "it should fail bad phone creation" do
    post :create, phone:{}.to_json, format: :json
    assert_response 422
  end
  
  test "it should fail bad phone update" do
    put :update, id: @phone, phone: { number: "" }.to_json, format: :json
    assert_response 422
  end
end

