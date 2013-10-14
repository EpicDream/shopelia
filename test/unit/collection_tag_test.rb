require 'test_helper'

class CollectionTagTest < ActiveSupport::TestCase

  setup do
    @collection = collections(:got)
    @tag = Tag.create(name:"Tag")
  end

  test "it should create collection tag" do
    r = CollectionTag.new(collection_id:@collection.id, tag_id:@tag.id)
    assert r.save
  end

  test "it shouldn't associate same tag twice to collection" do
    r = CollectionTag.new(collection_id:@collection.id, tag_id:tags(:gameofthrones).id)
    assert !r.save
  end
end