# -*- encoding : utf-8 -*-
require 'test_helper'

class CollectionsTest < ActiveSupport::TestCase

  setup do
    @collection = collections(:got)
  end

  test "it should parametrize collection" do
    assert_equal "abcd-game-of-thrones", @collection.to_param

    @collection.update_attribute :name, nil
    assert_equal "abcd", @collection.to_param
  end

  test "it should create collection" do
    collection = Collection.new(
      user_id:users(:manu).id,
      name:"Game of Thrones",
      description:"description")

    assert collection.save
    assert_not_nil collection.uuid
    assert_equal "Game of Thrones", collection.name
    assert_equal "description", collection.description
  end

  test "it should set rank when public" do
    @collection.public = true
    @collection.save

    assert_equal 1, @collection.rank
  end

  test "it should associate with products" do
    assert_equal 2, @collection.products.count
  end

  test "it should associate with tags" do
    assert_equal 3, @collection.tags.count
  end

  test "it should set __Home tag when public" do
    collection = Collection.create

    assert_difference "collection.tags.count" do
      collection.update_attribute :public, true
    end
    assert_equal "__Home", collection.tags.first.name

    assert_difference "Tag.count", 0 do
      assert_difference "collection.tags.count", -1 do
        collection.update_attribute :public, false
      end
   end
  end
end
