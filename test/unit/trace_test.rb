require 'test_helper'

class TraceTest < ActiveSupport::TestCase

  setup do
    @user = users(:elarch)
    @device = devices(:samsung)
    @resource = "Georges"
    @action = "message"
    @extra_text = "bla"
    @ip_address = "127.0.0.1"
  end

  test "it should create trace" do
    trace = Trace.new(user_id:@user.id, device_id:@device.id, resource:@resource, action:@action, extra_text:@extra_text, ip_address:@ip_address)
    assert trace.save

    assert_equal @user.id, trace.user_id
    assert_equal @device.id, trace.device_id
    assert_equal @resource, trace.resource
    assert_equal @action, trace.action
    assert_equal @extra_text, trace.extra_text
    assert_equal @ip_address, trace.ip_address
  end

  test "it should set and update session" do
    assert_difference "UserSession.count" do
      Trace.create(user_id:@user.id, device_id:@device.id, resource:@resource, action:@action, extra_text:@extra_text, ip_address:@ip_address)
    end

    session = UserSession.first
    session.created_at = 10.minutes.ago
    session.updated_at = 10.minutes.ago
    session.save

    Trace.create(user_id:@user.id, device_id:@device.id, resource:@resource, action:@action, extra_text:@extra_text, ip_address:@ip_address)
    assert session.reload.updated_at.to_i > 1.minute.ago.to_i

    session.created_at = 100.minutes.ago
    session.updated_at = 100.minutes.ago
    session.save

    assert_difference "UserSession.count" do
      Trace.create(user_id:@user.id, device_id:@device.id, resource:@resource, action:@action, extra_text:@extra_text, ip_address:@ip_address)
    end
  end
end