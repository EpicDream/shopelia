# -*- encoding : utf-8 -*-
require 'test_helper'

class CollectionSerializerTest < ActiveSupport::TestCase
  
  setup do
    @collection = collections(:got)
  end
  
  test "it should correctly serialize collection" do
    collection_serializer = CollectionSerializer.new(@collection)
    hash = collection_serializer.as_json
    
    assert_equal @collection.uuid, hash[:collection][:uuid]
    assert_equal @collection.name, hash[:collection][:name]
    assert_equal Shopelia::Application.config.image_host + @collection.image.url, hash[:collection][:image_url]
    assert_equal @collection.tags.map(&:name), hash[:collection][:tags]
    assert_equal @collection.collection_items.count, hash[:collection][:size]
  end
end