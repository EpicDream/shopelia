require 'test_helper'

class UserSessionTest < ActiveSupport::TestCase

  setup do
    @user = users(:elarch)
    @device = devices(:samsung)
  end

  test "it should create session with device" do
    session = UserSession.new(device_id:@device.id)
    assert session.save
  end

  test "it should create session with device and user" do
    session = UserSession.new(device_id:@device.id, user_id:@user.id)
    assert session.save

    assert_equal @device.id, session.device_id
    assert_equal @user.id, session.user_id
  end

  test "it should set active" do
    session = UserSession.create(device_id:@device.id)
    assert session.active?

    session.created_at = 100.minutes.ago
    session.updated_at = 100.minutes.ago
    session.save

    assert !session.active?
  end
end