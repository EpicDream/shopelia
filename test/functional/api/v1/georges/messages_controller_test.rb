# -*- encoding : utf-8 -*-
require 'test_helper'

class Api::V1::Georges::MessagesControllerTest < ActionController::TestCase
  
  setup do
    @device = devices(:mobile)
  end

  test "it should create message" do
    assert_difference "Message.count" do
      post :create, message:"toto", visitor:@device.uuid, format: :json
      assert_response :success
    end
    assert_equal "toto", Message.last.content
    assert_equal @device.id, Message.last.device_id
  end
end