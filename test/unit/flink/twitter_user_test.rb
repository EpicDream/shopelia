require 'test_helper'

class TwitterUserTest < ActiveSupport::TestCase
  ACCESS_TOKEN = "2227040976-Jkc5ECH9w6KCqkdie80Ky0aEcY1WEBKRmS9vbrP"
  ACCESS_TOKEN_SECRET = "kM2QfGJu7Y6f1BfttO9rlapmoVPtpVeWifMTggLkS8ZZm"
  
  setup do
    @betty = TwitterUser.create(flinker_id:flinkers(:betty).id, twitter_id: "147937366", access_token:"11AAII")
  end
  
  test "create user from auth tokens and assign twitter friends who are also flinkers" do
    skip
    fanny = flinkers(:fanny)
    user = TwitterUser.init(fanny, ACCESS_TOKEN, ACCESS_TOKEN_SECRET)

    assert_equal [@betty], user.friendships
    assert_equal "Flink", user.username
  end
  
  test "refresh token and friends only if exists" do
    skip
    fanny = TwitterUser.create(flinker_id:flinkers(:fanny).id, twitter_id: "2227040976", access_token:ACCESS_TOKEN, access_token_secret: ACCESS_TOKEN_SECRET)
    user = nil
    
    assert_no_difference 'InstagramUser.count' do
      user = TwitterUser.init(flinkers(:fanny), ACCESS_TOKEN, ACCESS_TOKEN_SECRET)
    end
    
    assert_equal fanny, user
    assert_equal [@betty], user.friendships
  end
end