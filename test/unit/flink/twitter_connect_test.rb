require 'test_helper'
require 'social/twitter/twitter_connect'

class TwitterConnectTest < ActiveSupport::TestCase
  ACCESS_TOKEN = "2227040976-Jkc5ECH9w6KCqkdie80Ky0aEcY1WEBKRmS9vbrP"
  ACCESS_TOKEN_SECRET = "kM2QfGJu7Y6f1BfttO9rlapmoVPtpVeWifMTggLkS8ZZm"
  
  test "connection" do
    skip
    client = TwitterConnect.new(ACCESS_TOKEN, ACCESS_TOKEN_SECRET)

    me = client.me
    p me.id
    p client.friends_ids
  end
end
