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
  
  test "when a hashtag is removed from a look, iff hashtag does not belong to any look, remove it" do
    @look.hashtags << @hashtags
    looks(:quimper).hashtags << @hashtags.last
    
    @look.hashtags.destroy(@hashtags)
    
    assert_equal ["fashion"], Hashtag.all.map(&:name)
  end
  
  test "hashtags must be found case insensitive and hashtagified" do
    assert_difference('Hashtag.count', 0) do
      hashtag = Hashtag.find_or_create_by_name('Mode')
      assert_equal @hashtags.first, hashtag
    end
    
    hashtag = Hashtag.find_or_create_by_name('Mode de Laura é')
    assert_equal "ModedeLaurae", hashtag.name
  end
end
