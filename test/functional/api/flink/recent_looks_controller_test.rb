require 'test_helper'

class Api::Flink::RecentLooksControllerTest < ActionController::TestCase     
  include Devise::TestHelpers

  setup do
    @flinker = flinkers(:betty)
    sign_in @flinker
    Look.all.each { |look| 
      look.update_attributes(is_published:true, flink_published_at:Date.today - 2.days) 
    }
  end

  test "get first 20 recent published looks" do
    get :index, format: :json

    assert_response :success
    looks = json_response["looks"]
    
    assert_equal Look.published.count, looks.count
  end
  
  test "get recent looks published after" do
    date = Time.now - 1.day
    Look.last.update_attributes(flink_published_at:date) 

    get :index, format: :json, flink_published_after:date.to_i

    assert_response :success, 
    looks = json_response["looks"]
    
    assert_equal 1, looks.count
  end
  

end