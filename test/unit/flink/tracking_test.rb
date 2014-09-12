require 'test_helper'

class TrackingTest < ActiveSupport::TestCase

  test "look uuid must be present" do
    assert_no_difference("Tracking.count") do
      Tracking.create(event: "seelook")
    end
  end

  test "don't check look uuid presence if notification tracking" do
    assert_difference("Tracking.count") do
      Tracking.create(event: "openpush", read: true, notification_id: 2)
    end
  end
end