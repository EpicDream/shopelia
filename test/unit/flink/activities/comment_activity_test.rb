require 'test_helper'

class CommentActivityTest < ActiveSupport::TestCase
  
  setup do
    @commenter = flinkers(:boop)
  end
  
  test "create comment activity for friends of commenter only" do
    
    assert_difference("CommentActivity.count", 2) do
      CommentActivity.create!(comments(:agadir)) #boop comment
    end
    
    assert @commenter.friends.count > 0
    assert_equal @commenter.friends.to_set, CommentActivity.all.map(&:target).to_set
  end
  
  test "don't create comment activity if related timeline activity exists" do
    comment = comments(:agadir)
    target = flinkers(:fanny)
    CommentTimelineActivity.create(flinker_id:comment.flinker_id, target_id:target.id, resource_id:comment.id)
    
    assert_difference("CommentActivity.count", 1) do
      CommentActivity.create!(comments(:agadir))
    end
  end
  
end