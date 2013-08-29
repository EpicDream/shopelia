require 'test_helper'

class DeviceTest < ActiveSupport::TestCase
  
  test "it should create device" do
    device = Device.new(user_agent:"UA")
    assert device.save, device.errors.full_messages.join("\n")
    assert_equal 32, device.uuid.length
  end
  
  test "it should fetch device by uuid" do
    assert_difference "Device.count", 1 do
      device = Device.fetch("new_uuid", "UA")
      assert_equal "new_uuid", device.uuid
    end
    
    assert_difference "Device.count", 0 do
      device = Device.fetch("new_uuid", "UA")
    end
  end
  
end
