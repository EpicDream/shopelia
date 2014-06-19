require 'test_helper'

class Api::Flink::Followings::UpdatedLooksControllerTest < ActionController::TestCase     
  include Devise::TestHelpers

  setup do
    @flinker = flinkers(:fanny)
    @publishers = [flinkers(:betty), flinkers(:lilou)]
    populate_looks_for @publishers
    sign_in @flinker
  end

  test "looks updated of current flinker followings ordered by updated_at asc" do
    follow flinkers(:betty)
    follow flinkers(:lilou)
    update_looks(3)
    
    get :index, format: :json, updated_after: 3.minutes.ago.to_i
    
    assert_response :success
    
    looks = json_response["looks"]
    assert_equal 3, looks.count
    assert looks.first["updated_at"] < looks.last["updated_at"]
  end
  
  private
  
  def update_looks n
    Look.limit(n).each_with_index { |look, idx| look.updated_at = (n - idx).minutes.ago + 1; look.save! }
  end
  
end