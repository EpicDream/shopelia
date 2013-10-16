require 'test_helper'

class ScanLogTest < ActiveSupport::TestCase

  test "it should create scan log" do
    log = ScanLog.new(
      ean:"3228020481464",
      device_id:devices(:web).id,
      prices_count:2)
    assert log.save
  end
end