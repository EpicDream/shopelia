require 'test_helper'

class CommentActivityTest < ActiveSupport::TestCase
  
  setup do
    @commenter = flinkers(:boop)
    Comment.any_instance.stubs(:can_be_posted_on_blog?)
  end
  
  test "create comment activity for friends of commenter only" do
    #boop has one comment on agadir look
    friend = @commenter.friends.first
    assert_difference("CommentActivity.count", 2) do
      Comment.create(body:"Yes!", look_id:looks(:agadir).id, flinker_id:friend.id)
    end
    
    assert_equal 2, CommentActivity.count
    assert_equal 1, CommentTimelineActivity.count
    assert_equal friend.friends.to_set, CommentActivity.all.map(&:target).to_set
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