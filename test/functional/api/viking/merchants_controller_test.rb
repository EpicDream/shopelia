require 'test_helper'

class Api::Viking::MerchantsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  fixtures :merchants
  
  setup do
    @merchant = merchants(:amazon)
  end

  test "it should send data for merchant" do
    get :show, id:@merchant.id
    
    assert_response :success   
    assert json_response["data"].present?
  end
  
  test "it should update merchant data" do
    post :update, id:@merchant.id, data:{"bla" => "bing"}
    
    assert_response :success
    assert_equal ({"bla" => "bing"}.to_json), @merchant.reload.viking_data
  end
  
end

