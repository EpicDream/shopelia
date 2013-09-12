require 'test_helper'

class Api::V1::ProductsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "it should extract Fnac product informations" do
    get :index, url:"http://ad.zanox.com/ppc/?19054231C2048768278&ULP=%5B%5Bjeux-jouets.fnac.com/a3619752/Lego-Duplo-Cars-5813-Flash-McQueen%5D%5D#fnac.com"
    assert_response :success
  end

  test "it should fail bad url" do
    get :index, url:"bla"
    assert_response :success
    
    assert json_response.empty?
  end

  test "it should send developer scope to product versions in order to compute cashfront value" do
    get :index, url:products(:dvd).url
    assert_response :success

    assert_equal 0.30, json_response["versions"][0]["cashfront_value"], json_response.inspect
  end

  test "it should manage multiple urls" do
    post :create, urls:[products(:dvd).url, products(:dvd).url]
    assert_response :success

    assert_equal 2, json_response.count
    assert_equal 0.30, json_response[0]["versions"][0]["cashfront_value"]
  end
end