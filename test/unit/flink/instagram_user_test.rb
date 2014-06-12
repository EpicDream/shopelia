require 'test_helper'

class InstagramUserTest < ActiveSupport::TestCase
  
  test "create user from auth token and assign instagram friends who are also flinkers" do
    betty = InstagramUser.create(flinker_id:flinkers(:betty).id, instagram_id: 601982481, access_token:"11AAII")
    fanny = flinkers(:fanny)
    token = "1342966740.23adf90.47da68287c0a4a81a1fe6218e875df2c"

    user = InstagramUser.init(fanny, token)

    assert_equal [betty], user.friendships
  end
end