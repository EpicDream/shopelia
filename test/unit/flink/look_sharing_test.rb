require 'test_helper'

class LookSharingTest < ActiveSupport::TestCase
  
  setup do
    @look = looks(:agadir)
    @flinker = flinkers(:lilou)
  end
  
  test "create with social network name" do
    assert_difference('LookSharing.count') do
      LookSharing.on("twitter").for(look_id:@look.id, flinker_id:@flinker.id)
    end
  end
  
  test "no creation with social network name does not exists" do
    assert_no_difference('LookSharing.count') do
      LookSharing.on("bzh-network").for(look_id:@look.id, flinker_id:@flinker.id)
    end
  end
  
  test "create share activities when created with twitter or facebook social networks" do
    follow(@flinker, flinkers(:fanny))
    follow(@flinker, flinkers(:boop))
    
    assert_difference('ShareActivity.count', 4) do
      LookSharing.on("twitter").for(look_id:@look.id, flinker_id:@flinker.id)
      LookSharing.on("facebook").for(look_id:@look.id, flinker_id:@flinker.id)
    end
  end
  
  test "dont create share activity unless twitter or facebook" do
    follow(@flinker, flinkers(:fanny))
    follow(@flinker, flinkers(:boop))
    
    assert_no_difference('ShareActivity.count') do
      LookSharing.on("mail").for(look_id:@look.id, flinker_id:@flinker.id)
    end
  end
end
