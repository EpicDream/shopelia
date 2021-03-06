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
  
  test "it should create device from user_agent" do
    ua = "shopelia:os[Android]:build[1]:version[1.0.1]:os_version[4.4]:phone[Samsung Galaxy]:uuid[abcdefghi]:dev[1]"
    assert_difference "Device.count" do 
      device = Device.from_user_agent(ua)
      assert_equal "abcdefghi", device.uuid
      assert_equal "Samsung Galaxy", device.phone
      assert_equal "4.4", device.os_version
      assert_equal "1.0.1", device.version
      assert_equal 1, device.build
      assert_equal "Android", device.os
      assert device.android?
      assert device.is_dev?
    end
  end

  test "it should fetch and update device from user_agent" do 
    ua = "shopelia:os[iOS]:build[1]:version[1.0.1]:os_version[4.4]:phone[Samsung Galaxy]:uuid[#{devices(:mobile).uuid}]"
    assert_difference "Device.count", 0 do 
      device = Device.from_user_agent(ua)
      assert_equal devices(:mobile).uuid, device.uuid
      assert_equal "Samsung Galaxy", device.phone
      assert_equal "4.4", device.os_version
      assert_equal "1.0.1", device.version
      assert_equal 1, device.build
      assert_equal "iOS", device.os
      assert device.ios?
      assert !device.is_dev?
    end
  end

  test "it should fetch and update device from user_agent (flink)" do 
    ua = "flink:os[iOS]:build[1]:version[1.0.1]:os_version[4.4]:phone[Samsung Galaxy]:uuid[#{devices(:mobile).uuid}]:dev[2]"
    assert_difference "Device.count", 0 do 
      device = Device.from_flink_user_agent(ua, flinkers(:betty))
      assert_equal devices(:mobile).uuid, device.uuid
      assert_equal "Samsung Galaxy", device.phone
      assert_equal "4.4", device.os_version
      assert_equal "1.0.1", device.version
      assert_equal 1, device.build
      assert_equal "iOS", device.os
      assert device.ios?
      assert !device.is_dev?
      assert device.is_beta?
      assert_equal flinkers(:betty).id, device.flinker_id
    end
  end
end