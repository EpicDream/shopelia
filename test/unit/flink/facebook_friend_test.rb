require 'test_helper'

class FacebookFriendTest < ActiveSupport::TestCase
  
  setup do
    @flinker = flinkers(:fanny)
    @fanny = flinker_authentications(:fanny)
  end
  
  test "create facebook friends from facebook graph and attach flinker if fb user if flinker" do
    FacebookFriend.delete_all
    FlinkerAuthentication.create!(provider:"facebook", uid:"521805306", flinker_id: flinkers(:boop).id)
    @fanny.update_attributes(flinker_id:@flinker.id)
    
    2.times { FacebookFriend.create_or_update_friends(@flinker) }

    friends = FacebookFriend.of_flinker(@flinker)
    assert_match /graph.facebook.com\/\d+\/picture\?width=200&height=200&type=normal/, friends.last.picture
    assert friends.last.username.length > 2
    assert friends.count.between?(15, 50)
    assert friends.last.sex
    assert_equal 1, FacebookFriend.of_flinker(@flinker).flinkers.count
    assert_equal friends.count - 1, FacebookFriend.of_flinker(@flinker).not_flinkers.count
  end
  
  test "fb friend must be unique on (flinker_id, identifier)" do
    assert_difference("FacebookFriend.count", 1) { 
      FacebookFriend.create(flinker_id:@flinker.id, identifier:"1202020202", name:"zero")
    }
  end
  
end
