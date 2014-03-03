require 'test_helper'

class FlinkerSerializerTest < ActiveSupport::TestCase
  
  setup do
    @flinker = flinkers(:betty)
  end
  
  test "serialize flinker" do
    serializer = FlinkerSerializer.new(@flinker)
    hash = serializer.as_json
      
    assert_equal @flinker.id, hash[:flinker][:id]
    assert_equal @flinker.name, hash[:flinker][:name]
    assert_equal @flinker.url, hash[:flinker][:url]
    assert_equal Rails.configuration.image_host + @flinker.avatar.url(:thumb), hash[:flinker][:avatar]
    assert_equal 1, hash[:flinker][:staff_pick]
    assert_equal "FR", hash[:flinker][:country]
    assert_equal 2, hash[:flinker][:liked_count]
  end
  
  test "serialize non publisher without liked count" do
    flinker = flinkers(:fanny)
    hash = FlinkerSerializer.new(flinker).as_json
    
    assert !hash[:flinker].has_key?(:liked_count)
  end
  
end