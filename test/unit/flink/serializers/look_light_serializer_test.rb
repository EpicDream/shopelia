require 'test_helper'

class LookSerializerTest < ActiveSupport::TestCase
  
  setup do
    @look = Look.last
  end
  
  test "serialize light look" do
    @look.update_attributes(flink_published_at:Time.now + 1.day, staff_pick:true)
    look_serializer = LookLightSerializer.new(@look, flinker:Flinker.last)
    hash = look_serializer.as_json
  end

end
