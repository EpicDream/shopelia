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
      assert json_response["timestamp"] > 0
    end
    assert_equal "toto", Message.last.content
    assert_equal @device.id, Message.last.device_id
  end

  test "it should set message read_at" do
    post :create, message:"toto", visitor:@device.uuid, format: :json
    message = Message.last

    get :read, id:message.id, format: :json
    assert_not_nil message.reload.read_at
  end

  test "it should update message with gift card info" do
    message = Message.create!(device_id:@device.id, content:"toto")
    put :update, id:message.id, message:{gift_gender:"H", gift_age:"0-7", gift_budget:"50€"}, format: :json

    assert_response :success
    assert_equal "H", message.reload.gift_gender
    assert_equal "0-7", message.reload.gift_age
    assert_equal "50€", message.reload.gift_budget
  end
end