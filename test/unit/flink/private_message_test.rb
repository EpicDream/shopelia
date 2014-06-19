require 'test_helper'

class PrivateMessageTest < ActiveSupport::TestCase
  
  test "presence of flinker and target" do
    assert !PrivateMessage.new(content:"hello").valid?
    assert !PrivateMessage.new(content:"hello", flinker_id:flinkers(:betty).id).valid?
  end
  
  test "create private message, create private message activity for targeted flinker" do
    flinker = flinkers(:betty)
    target = flinkers(:nana)
    look = looks(:quimper)
    
    assert_difference 'PrivateMessageActivity.count' do
      assert_no_difference 'PrivateMessageAnswerActivity.count' do
        PrivateMessage.create(content:"hello", flinker_id:flinker.id, target_id:target.id, look_id:look.id, answer:false)
      end
    end
  
    message = PrivateMessage.last
    activity = PrivateMessageActivity.last

    assert_equal flinker.id, activity.flinker_id
    assert_equal target.id, activity.target_id
    assert_equal message, activity.resource
  end
  
  test "if message is an answer, create PrivateMessageAnswerActivity for target" do
    flinker = flinkers(:betty)
    target = flinkers(:nana)
    look = looks(:quimper)
    
    assert_difference 'PrivateMessageAnswerActivity.count' do
      PrivateMessage.create(content:"hello", flinker_id:flinker.id, target_id:target.id, look_id:look.id, answer:true)
    end
  
    activity = PrivateMessageAnswerActivity.last
    message = PrivateMessage.last

    assert_equal flinker.id, activity.flinker_id
    assert_equal target.id, activity.target_id
    assert_equal message, activity.resource
  end
  
end