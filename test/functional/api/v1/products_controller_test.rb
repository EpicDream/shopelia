require 'test_helper'

class Api::V1::ProductsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "it should extract Fnac product informations" do
    get :index, url:"http://ad.zanox.com/ppc/?19054231C2048768278&ULP=%5B%5Bjeux-jouets.fnac.com/a3619752/Lego-Duplo-Cars-5813-Flash-McQueen%5D%5D#fnac.com"
    assert_response :success
  end

  test "it should fail bad url" do
    get :index, url:"bla"
    assert_response :not_found
  end

end

