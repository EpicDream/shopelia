require 'test_helper'

class LikeActivityTest < ActiveSupport::TestCase
  
  setup do
    @liker = flinkers(:boop)
  end
  
  test "create like activity for friends of liker only" do
    
    assert_difference("LikeActivity.count", 2) do
      LikeActivity.create!(flinker_likes(:boop_like)) #boop likes
    end
    
    assert @liker.friends.count > 0
    assert_equal @liker.friends.to_set, LikeActivity.all.map(&:target).to_set
  end
  
  test "dont create like activity if resource is product" do
    assert_no_difference("LikeActivity.count") do
      LikeActivity.create!(flinker_likes(:three))
    end
  end
  
end