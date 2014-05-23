require 'test_helper'

class Api::Flink::PopularLooksControllerTest < ActionController::TestCase     
  include Devise::TestHelpers

  setup do
    @flinker = flinkers(:betty)
    sign_in @flinker
  end

  test "get first 20 popular looks" do
    get :index, format: :json

    assert_response :success
  end

end