require 'test_helper'

class Api::V1::MerchantsControllerTest < ActionController::TestCase
  fixtures :merchants

  test "it should get all merchants" do
    get :index, format: :json
    assert_response :success
    
    assert json_response.kind_of?(Array), "Should get an array of merchants"
    assert_equal Merchant.all.count, json_response.count
  end

  test "it shouldn't find merchant for unsupported url" do
    post :create, url:"http://www.toto.fr/bla", format: :json
    assert_response :not_found
  end

  test "it should find merchant for supported url" do
    post :create, url:"http://www.rueducommerce.fr/bla", format: :json
    assert_response :success
    assert_equal merchants(:rueducommerce).id, json_response["merchant"]["id"]
  end
  
  test "it shouldn't send merchants not accepting order" do
    merchants(:amazon).update_attribute :accepting_orders, false
    get :index, format: :json
    assert_equal Merchant.all.count - 1, json_response.count
  end

end

