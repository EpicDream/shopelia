# -*- encoding : utf-8 -*-
require 'test_helper'

class Api::V1::TracesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @device = devices(:samsung)
    @user = users(:elarch)
    @trace = {
      resource:"George",
      action:"message",
      extra_text:"bla"
    }
  end

  test "it should create event without user" do
    assert_difference "TracesWorker.jobs.count" do
      post :create, traces:[@trace], visitor:@device.uuid, format: :json
      assert_response :success
    end
    
    assert_difference ["Trace.count","UserSession.count"] do
      TracesWorker.drain
    end

    trace = Trace.all.first
    assert_equal @device.id, trace.device_id
    assert trace.user_id.nil?
    assert trace.extra_id.nil?
    assert_equal "George", trace.resource
    assert_equal "message", trace.action
    assert_equal "bla", trace.extra_text
  end

  test "it should create event with user" do
    sign_in @user
    @trace[:extra_id] = 1

    assert_difference "TracesWorker.jobs.count" do
      post :create, traces:[@trace], visitor:@device.uuid, format: :json
      assert_response :success
    end
    
    assert_difference ["Trace.count","UserSession.count"] do
      TracesWorker.drain
    end

    trace = Trace.all.first
    assert_equal @device.id, trace.device_id
    assert_equal @user.id, trace.user_id
    assert_equal 1, trace.extra_id
  end
end