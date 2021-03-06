# encoding: UTF-8
require 'test__helper'
require 'anne_fashion/instagram'

class AnneFashion::InstagramTest < ActiveSupport::TestCase
  
  #https://instagram.com/oauth/authorize/?client_id=845aac06f9bc40b69a521cef5611d7de&redirect_uri=http://localhost:3000&response_type=token&scope=likes+comments+relationships

  setup do
    @client = AnneFashion::Instagram.new
  end
  
  test "authentication" do
    skip
    assert_equal 'flinkhq', @client.me.id
  end
  
  test "follow and like by tag" do
    skip
    @client.follow_and_like_by_tag('fashion')
  end
  
  test "followings" do
    skip
    assert_equal 137, @client.followings.count
  end
  
  test "followers" do
    skip
    assert_equal 75, @client.followers.count
  end
  
  test "schedule following" do
    skip
    @client.schedule_follow_ratio
  end
  
  test "follow friends of followers" do
    skip
    @client.follow_friends_of_followers
  end
  
end
