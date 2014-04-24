require 'test_helper'

class WS::FlinkerSerializerTest < ActiveSupport::TestCase
  
  setup do
    @flinker = flinkers(:betty)
    follow(@flinker, flinkers(:fanny))
  end
  
  test "serialize flinker" do
    serializer = WS::FlinkerSerializer.new(@flinker)
    flinker = serializer.as_json
    
    assert_equal 8, flinker[:uuid].size
    assert_equal "bettyusername", flinker[:username]
    assert_equal 1, flinker[:counters][:looks]
    assert_equal 1, flinker[:counters][:followers]
    assert_equal 2, flinker[:counters][:likes]
  end
end