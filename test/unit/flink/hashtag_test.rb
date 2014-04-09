require 'test_helper'

class HashtagTest < ActiveSupport::TestCase
  
  setup do
    @hashtags = [Hashtag.create(name:"mode"), Hashtag.create(name:"fashion")]
    @look = looks(:agadir)
  end
  
  test "delete hashtag should remove looks hashtag associations" do
    @look.hashtags << @hashtags

    assert_equal 2, @look.hashtags.count
    
    @hashtags.first.destroy
    
    assert_equal 1, @look.reload.hashtags.count
  end
  
  test "when a hashtag is removed from a look, if hashtag does not belong to any look, remove it from algolia index" do
    @look.hashtags << @hashtags
    looks(:quimper).hashtags << @hashtags.last
    
    @hashtags.first.expects(:algolia_remove_from_index!)
    @hashtags.last.expects(:algolia_remove_from_index!).never
    
    @look.hashtags.destroy(@hashtags)
    
    assert_equal 2, Hashtag.count
  end
  
end
