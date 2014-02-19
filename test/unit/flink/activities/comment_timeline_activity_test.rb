require 'test_helper'

class CommentTimelineActivityTest < ActiveSupport::TestCase

  setup do
    Comment.any_instance.stubs(:can_be_posted_on_blog?).returns(false)
  end
  
  test "create comment timeline activity for flinkers who have already commented on same look" do
    initial_comment = comments(:agadir) #boop comment
    Comment.create!(body:"Cool!", look_id:initial_comment.look.id, flinker_id:flinkers(:lilou).id) #lilou comment
    
    commenter = flinkers(:fanny)
    
    assert_difference("CommentTimelineActivity.count", 2) do
      Comment.create!(body:"Cool!", look_id:initial_comment.look.id, flinker_id:commenter.id) #fanny comment
    end
    
    activity = CommentTimelineActivity.last
    
    assert_equal [flinkers(:boop), flinkers(:lilou)].to_set, CommentTimelineActivity.all.map(&:target).to_set
    assert_equal Comment.last, activity.resource
    assert_equal flinkers(:lilou), activity.target
    assert_equal commenter, activity.flinker
    assert_equal initial_comment.look.uuid, activity.look_uuid
  end
  
  test "ensure no duplicated timeline activities" do
    comment = comments(:agadir)
    assert_difference("CommentTimelineActivity.count", 1) do
      CommentTimelineActivity.create(flinker_id:comment.flinker_id, target_id:flinkers(:fanny).id, resource_id:comment.id)
    end
  end
  
  test "no timeline activity if look not already commented" do
    comments(:agadir).destroy
    
    assert_no_difference("CommentTimelineActivity.count") do
      Comment.create!(body:"Cool!", look_id:looks(:agadir).id, flinker_id:flinkers(:fanny).id)
    end
    
  end
  
end
