require 'test_helper'

class FollowActivityTest < ActiveSupport::TestCase
  
  setup do
    @flinker = flinkers(:lilou)
    @followed = flinkers(:betty)
  end
  
  test "send follow notification to followed flinker when follow activity is created" do
    Sidekiq::Testing.inline! do 
      Flink::FollowNotification.expects(:new).with(@followed, @flinker).returns(stub(:deliver => nil))
      FlinkerFollow.create(flinker_id:@flinker.id, follow_id:@followed.id)
    end
  end
end
