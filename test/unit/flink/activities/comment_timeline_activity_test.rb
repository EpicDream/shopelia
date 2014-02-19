require 'test_helper'

class CommentTimelineActivityTest < ActiveSupport::TestCase

  setup do
    Comment.any_instance.stubs(:can_be_posted_on_blog?).returns(false)
  end
  
  test "create comment timeline activity for flinkers who have already commented on same look" do
    initial_comment = comments(:agadir) #boop comment
    commenter = flinkers(:fanny)
    
    assert_difference("CommentTimelineActivity.count", 1) do
      Comment.create!(body:"Cool!", look_id:initial_comment.look.id, flinker_id:commenter.id) #fanny comment
    end
    
    activity = CommentTimelineActivity.last
    
    assert_equal Comment.last, activity.resource
    assert_equal flinkers(:boop), activity.target
    assert_equal commenter, activity.flinker
    assert_equal initial_comment.look.uuid, activity.look_uuid
  end
  
  test "no timeline activity if look not already commented" do
    comments(:agadir).destroy
    
    assert_no_difference("CommentTimelineActivity.count") do
      Comment.create!(body:"Cool!", look_id:looks(:agadir).id, flinker_id:flinkers(:fanny).id)
    end
    
  end
  
end
