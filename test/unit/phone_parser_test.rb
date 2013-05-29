require 'test_helper'

class PhoneParserTest < ActiveSupport::TestCase
 
  test "[FR] 0646403619 should be mobile" do
    assert PhoneParser.is_mobile?("0646403619", "fr")
  end  

  test "[FR] 0746403619 should be mobile" do
    assert PhoneParser.is_mobile?("0746403619", "fr")
  end  

  test "[FR] 0248515290 should not be mobile" do
    assert !PhoneParser.is_mobile?("0248515290", "fr")
  end  

end
