require 'test_helper'

class Api::Flink::PopularLooksControllerTest < ActionController::TestCase     
  include Devise::TestHelpers

  setup do
    @flinker = flinkers(:betty)
    sign_in @flinker
    Look.all.each { |look| look.update_attributes(is_published:true) }
    Look.send(:remove_const, :MIN_LIKES_FOR_POPULAR)
    Look.const_set(:MIN_LIKES_FOR_POPULAR, 1)
  end

  test "get first 20 popular looks" do
    get :index, format: :json

    assert_response :success
    looks = json_response["looks"]
    
    assert_equal 1, looks.count
  end

end