# -*- encoding : utf-8 -*-
require 'test_helper'

class FlinklerSerializerTest < ActiveSupport::TestCase
  
  setup do
    @flinker = flinkers(:betty)
  end
  
  test "it should correctly serialize flinker" do
    flinker_serializer = FlinkerSerializer.new(@flinker)
    hash = flinker_serializer.as_json
      
    assert_equal @flinker.id, hash[:flinker][:id]
    assert_equal @flinker.name, hash[:flinker][:name]
    assert_equal @flinker.url, hash[:flinker][:url]
    assert_equal Rails.configuration.image_host + @flinker.avatar.url(:thumb), hash[:flinker][:avatar]
    assert_equal 1, hash[:flinker][:staff_pick]
    assert_equal "FR", hash[:flinker][:country]
  end
end