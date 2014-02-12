require 'test_helper'

class FacebookFriendTest < ActiveSupport::TestCase
  
  setup do
    @flinker = flinkers(:fanny)
    @fanny = flinker_authentications(:fanny)
  end
  
  test "create facebook friends from facebook graph and attach flinker if fb user if flinker" do
    @fanny.update_attributes(flinker_id:@flinker.id)
    
    2.times { FacebookFriend.create_or_update_friends(@flinker) }

    assert_equal 518, FacebookFriend.of_flinker(@flinker).count
    assert_equal 1, FacebookFriend.flinker_friends_of(@flinker).count
  end
  
  test "fb friend must be unique on (flinker_id, identifier)" do
    assert_difference("FacebookFriend.count", 1) { 
      FacebookFriend.create(flinker_id:@flinker.id, identifier:"1202020202", name:"zero")
    }
  end
  
end
