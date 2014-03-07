require 'test_helper'

class MentionActivityTest < ActiveSupport::TestCase
  
  setup do
    @flinker = flinkers(:fanny)
    @commenter = flinkers(:boop)
  end
  
  test "mentionned scope" do
    MentionActivity.create!(comments(:agadir))
    
    mentions = MentionActivity.mentionned(@flinker)
    assert_equal @flinker, mentions.first.target
  end
  
  test "send notification to mentionned flinkers" do
    comment = comments(:agadir)
    comment.update_attributes(body:"@fanny regarde!")
    
    MentionNotificationWorker.expects(:perform_async).with(@flinker.id, @commenter.id)
    MentionActivity.create!(comment)
  end
  
end