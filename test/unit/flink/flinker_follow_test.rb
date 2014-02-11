require 'test_helper'

class FlinkerFollowTest < ActiveSupport::TestCase

  setup do
    @flinker = flinkers(:lilou)
    @followed = flinkers(:betty)
  end

  test "create flinker follow unique on (flinker_id, follow_id)" do
    follow = nil

    assert_difference(['FlinkerFollow.count', '@followed.reload.follows_count'], 1) do
      2.times {
        follow = FlinkerFollow.create(flinker_id:@flinker.id, follow_id:@followed.id)
      }
    end

    assert_equal @followed, follow.following
  end
  
  test "create follow activity after flinker_follow creation" do
    assert_difference('FollowActivity.count', 1) do
      2.times {
        FlinkerFollow.create(flinker_id:@flinker.id, follow_id:@followed.id)
      }
    end
    
    activity = FollowActivity.last
    assert_equal @flinker, activity.flinker
    assert_equal @followed, activity.target
    assert_equal FlinkerFollow.last, activity.resource
  end
  
end
