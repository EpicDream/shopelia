require 'test_helper'

class CommentActivityTest < ActiveSupport::TestCase
  
  setup do
    @commenter = flinkers(:boop)
    Comment.any_instance.stubs(:can_be_posted_on_blog?)
  end
  
  test "create comment activity for followers of commenter only" do
    Sidekiq::Testing.inline! do
      follow(@commenter, flinkers(:elarch))
      follow(@commenter, flinkers(:fanny))
    
      assert_difference("CommentActivity.count", 2) do
        Comment.create(body:"Yes!", look_id:looks(:agadir).id, flinker_id:@commenter.id)
      end
    
      assert_equal 2, CommentActivity.count
      assert_equal @commenter.followers.to_set, CommentActivity.all.map(&:target).to_set
    end
  end
  
  test "dont create comment activity if related timeline activity exists" do
    friends = @commenter.friends
    Comment.create(body:"Yes!", look_id:looks(:agadir).id, flinker_id:friends.first.id)
    Comment.create(body:"Yes!", look_id:looks(:agadir).id, flinker_id:friends.second.id)
    
    assert_no_difference("CommentActivity.count") do
      assert_difference("CommentTimelineActivity.count", 2) do
        Comment.create(body:"Yes!", look_id:looks(:agadir).id, flinker_id:@commenter.id)
      end
    end
  end
  
end