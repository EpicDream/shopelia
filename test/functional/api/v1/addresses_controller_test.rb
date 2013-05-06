require 'test_helper'

class Api::V1::AddressesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  fixtures :users, :addresses, :countries

  setup do
    @user = users(:elarch)
    sign_in @user
    @address = addresses(:elarch_neuilly)
  end

  test "it should create address" do
    assert_difference('Address.count', 1) do
      post :create, address: {
        code_name: "Office",
        address1: "21 rue d'Aboukir",
        zip: "75002",
        city: "Paris",
        country_id: countries(:france).id }, format: :json
    end
    
    assert_response :success
  end

  test "it should show address" do
    get :show, id: @address, format: :json
    assert_response :success
  end

  test "it should get all addresses for user" do
    get :index, format: :json
    assert_response :success
    
    assert json_response.kind_of?(Array), "Should get an array of addresses"
    assert_equal 2, json_response.count
  end

  test "it should update address" do
    put :update, id: @address, address: { address2: "RDC porte gauche" }, format: :json
    assert_response 204
  end

  test "it should destroy address" do
    assert_difference('Address.count', -1) do
      delete :destroy, id: @address, format: :json
    end

    assert_response 204
  end

  test "it shouldn't retrieve non existing address" do
    get :show, id: 123456, format: :json
    assert_response 404
  end

  
  test "it should fail bad address creation" do
    post :create, address:{}, format: :json
    assert_response 422
  end
  
  test "it should fail bad address update" do
    put :update, id: @address, address: { address1: "" }, format: :json
    assert_response 422
  end  
end

