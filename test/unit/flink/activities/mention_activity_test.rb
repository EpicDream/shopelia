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
  
end