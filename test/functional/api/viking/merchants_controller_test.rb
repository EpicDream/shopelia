require 'test_helper'

class Api::Viking::MerchantsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @merchant = merchants(:amazon)
  end

  test "it should find merchant by url" do
    get :index, url:"http://www.rueducommerce.fr/bla"
    assert_response :success
    assert_equal merchants(:rueducommerce).id, json_response["id"]
  end

  test "it should find all merchants" do
    get :index, format: :json
    assert_response :success
    assert_kind_of Integer, json_response["totalCount"]
    assert_kind_of Array, json_response["supportedBySaturn"]
  end

  test "it should send data for merchant" do
    get :show, id:@merchant.id
    
    assert_response :success   
    assert json_response["data"].present?
  end
  
  test "it should update merchant data" do
    put :update, id:@merchant.id, data:{"bla" => "bing"}
    
    assert_response :success
    assert_equal ({"bla" => "bing"}.to_json), @merchant.reload.viking_data
  end

  test "it should update merchant mapping_id" do
    map = mappings(:fnac_map)
    assert_nil @merchant.mapping_id
    put :update, id: @merchant.id, mapping_id: map.id
    assert_response 204
    assert_equal map.id, @merchant.reload.mapping_id
  end
end

