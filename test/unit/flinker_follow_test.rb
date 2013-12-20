require 'test_helper'

class FlinkerFollowTest < ActiveSupport::TestCase

  setup do
    @flinker = flinkers(:elarch)
  end

  test "it should create flinker follow" do
    follow = FlinkerFollow.new(flinker_id:@flinker.id, follow_id:flinkers(:betty).id)
    assert follow.save

    follow = FlinkerFollow.new(flinker_id:@flinker.id, follow_id:flinkers(:betty).id)
    assert !follow.save
  end
end