require 'test_helper'

class LikeActivityTest < ActiveSupport::TestCase
  
  setup do
    @liker = flinkers(:boop)
    follow(@liker, flinkers(:elarch))
    follow(@liker, flinkers(:fanny))
  end
  
  test "create like activity for followers of liker only" do
    Sidekiq::Testing.inline! do
      assert_difference("LikeActivity.count", 2) do
        LikeActivity.create!(flinker_likes(:boop_like)) #boop likes
      end
    end
    assert @liker.friends.count > 0
    assert_equal @liker.followers.to_set, LikeActivity.all.map(&:target).to_set
  end
  
  test "dont create like activity if resource is product" do
    Sidekiq::Testing.inline! do
      assert_no_difference("LikeActivity.count") do
        LikeActivity.create!(flinker_likes(:three))
      end
    end
  end
  
  test "when flinker like is destroyed, the activities for this resource must be destroyed too" do
    Sidekiq::Testing.inline! do
      LikeActivity.create!(flinker_likes(:boop_like))
      LikeActivity.create!(flinker_likes(:boop_like_two))
    
      assert_difference("LikeActivity.count", -2) do
        flinker_likes(:boop_like).destroy
      end
    end
  end
  
end