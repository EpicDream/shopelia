require 'test_helper'

class FollowActivityTest < ActiveSupport::TestCase
  
  setup do
    @flinker = flinkers(:lilou)
    @followed = flinkers(:betty)
  end
  
  test "send follow notification to followed flinker when follow activity is created" do
    Sidekiq::Testing.inline! do 
      FollowNotificationWorker.unstub(:perform_in)
      
      Flink::FollowNotification.expects(:new).with(@followed, @flinker).returns(stub(:deliver => nil))
      FlinkerFollow.create(flinker_id:@flinker.id, follow_id:@followed.id)
    end
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
  
  test "destroy follow activities to related FlinkerFollow resource when destroyed" do
    follow = FlinkerFollow.create(flinker_id:@flinker.id, follow_id:@followed.id)
    
    assert_difference("FollowActivity.count", -1) do
      follow.destroy
    end
    
  end
end
