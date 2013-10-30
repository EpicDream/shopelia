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

  test "it should associate with product versions" do
    assert_equal 2, @collection.product_versions.count
  end

  test "it should associate with tags" do
    assert_equal 2, @collection.tags.count
  end
end