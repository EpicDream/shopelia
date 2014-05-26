require 'test_helper'

class PrivateMessageTest < ActiveSupport::TestCase
  
  test "presence of flinker and target" do
    assert !PrivateMessage.new(content:"hello").valid?
    assert !PrivateMessage.new(content:"hello", flinker_id:flinkers(:betty).id).valid?
  end
  
  test "create private message" do
    assert_difference 'PrivateMessage.count' do
      PrivateMessage.create!(content:"hello", flinker_id:flinkers(:betty).id, target_id:flinkers(:nana).id)
    end
  end
  
end