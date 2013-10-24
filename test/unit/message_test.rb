require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  test "it should create message" do
    message = Message.new(content:"allo",device_id:1)
    assert message.save, message.errors.full_messages.join("\n")
    assert_equal "allo", message.content
  end

  test "it should get latest messages" do
    device = Device.create(user_agent:"UA")
    message1 = Message.create!({content:"allo",pending_answer:true})
    message2 = Message.create!({content:"test",pending_answer:true})
    device.messages = [message1,message2]
    assert device.save!, device.errors.full_messages.join("\n")
    assert_equal 1, Message.last_messages.count
    assert_equal "test", Message.last_messages[0].content
  end


  test "it should not get device where message is not pending answer" do
    device = Device.create(user_agent:"UA")
    message1 = Message.create!({content:"allo",pending_answer:false})
    device.messages = [message1]
    assert device.save!, device.errors.full_messages.join("\n")
    assert_equal 0, Message.last_messages.count
  end


end
