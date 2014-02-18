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
  
end