require 'test_helper'

class MessageTest < ActiveSupport::TestCase

  setup do
    @device = devices(:mobile)
  end

  test "it should create message" do
    message = Message.new(content:"allo",device_id:@device.id)
    assert message.save, message.errors.full_messages.join("\n")
    assert_equal "allo", message.content
  end

  test "it should serialize products_urls" do
    products_urls = "http://www.toto.com\nhttp://www.titi.com"
    message = Message.new(content:"allo",products_urls:products_urls,device_id:@device.id)
    assert message.save, message.errors.full_messages.join("\n")
    assert_equal [ "http://www.toto.com", "http://www.titi.com" ], message.data
  end

  test "it should open and close conversations" do
    @device.update_attribute :pending_answer, false
    Message.create(content:"allo",device_id:@device.id)
    assert @device.reload.pending_answer
    Message.create(content:"allo",device_id:@device.id,from_admin:true)
    assert !@device.reload.pending_answer
  end

  test "it should create a message if device is not pushable" do
    message = Message.new(content:"allo",device_id:devices(:web).id)
    assert !message.save
    assert_equal I18n.t('messages.errors.device_not_pushable'), message.errors.full_messages.first
  end

  test "it should send message to admin when user writes to Georges" do
    Message.create(content:"allo",device_id:@device.id)
    assert_equal 1, ActionMailer::Base.deliveries.count
    assert_equal "admin@shopelia.fr", ActionMailer::Base.deliveries.first.to[0]
    assert_equal 0, $push_delivery_count
  end

  test "it should push device when Georges writes back to user" do
    assert_difference "$push_delivery_count" do
      Message.create(content:"allo",device_id:@device.id,from_admin:true)
    end
  end
end