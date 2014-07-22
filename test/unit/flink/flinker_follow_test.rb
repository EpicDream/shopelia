require 'test_helper'

class FlinkerFollowTest < ActiveSupport::TestCase

  setup do
    @flinker = flinkers(:lilou)
    @followed = flinkers(:betty)
  end

  test "create flinker follow unique on (flinker_id, follow_id)" do
    assert_difference(['FlinkerFollow.count'], 1) do
      populate
    end

    assert_equal @followed, FlinkerFollow.last.following
  end
  
  test "default scope returns only follows with :on true" do
    populate
    count = FlinkerFollow.count
    follow = FlinkerFollow.last
    
    assert_difference("@flinker.reload.followings.count", - 1) do
      assert follow.update_attributes(on:false)
    end
    
    assert_equal count - 1, FlinkerFollow.count
  end
  
  private
  
  def populate
    2.times {
      FlinkerFollow.create(flinker_id:@flinker.id, follow_id:@followed.id)
    }
  end
  
end
