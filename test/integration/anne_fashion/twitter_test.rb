# encoding: UTF-8
require 'test__helper'
require 'anne_fashion/twitter'

class AnneFashion::TwitterTest < ActiveSupport::TestCase
  
  setup do
    @client = AnneFashion::Twitter.new
  end
  
  test "get twitter client" do
    assert @client.client
  end
  
  test "tweet message" do
    skip
    assert @client.twit("La mode Oui!!!!!")
  end
  
  test "follow user" do
    assert @client.follow([17221180, 755905303])
  end
  
  test "retweet tweet" do
    assert @client.retweet([413354572846202880])
  end
  
  test "follow from search results" do
    skip
    @client.follow_from_tweets("#lookbook")
  end
  
  test "tweets with user" do
    skip
    tweets = @client.tweets("#lookbook")
    assert tweets.count > 10
  end
  
  test "publish a fashion tweet" do
    skip
    @client.publish
  end
end