require 'test_helper'

class InstagramUserTest < ActiveSupport::TestCase
  TEST_TOKEN = "1342966740.23adf90.bf7e39ffb767488baf8fd51839f85b3d"
  
  setup do
    @betty = InstagramUser.create(flinker_id:flinkers(:betty).id, instagram_id: "601982481", access_token:"11AAII")
  end
  
  test "create user from auth token and assign instagram friends who are also flinkers" do
    skip
    fanny = flinkers(:fanny)
    user = InstagramUser.init(fanny, TEST_TOKEN)

    assert_equal [@betty], user.friendships
    assert_equal "pierrepollastri", user.username
    assert_equal "Pierre Pollastri", user.full_name
  end
  
  test "refresh token and friends only if exists" do
    skip
    fanny = InstagramUser.create(flinker_id:flinkers(:fanny).id, instagram_id: "60198248", access_token:TEST_TOKEN)
    user = nil
    
    assert_no_difference 'InstagramUser.count' do
      user = InstagramUser.init(flinkers(:fanny), TEST_TOKEN)
    end
    
    assert_equal fanny, user
    assert_equal [@betty], user.friendships
  end
end