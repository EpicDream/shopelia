# -*- encoding : utf-8 -*-
require 'test_helper'

class NexmoGatewayTest < ActiveSupport::TestCase
 
  test "it should sens sms" do
    assert_difference "$sms_gateway_count" do
      NexmoGateway.new.send_sms "+33646403616", "test"
    end
  end
end