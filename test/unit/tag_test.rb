require 'test_helper'

class TagTest < ActiveSupport::TestCase

  test "it should create tag" do
    tag = Tag.new(name:"Tag")
    assert tag.save

    tag = Tag.new(name:"Tag")
    assert !tag.save
  end

  test "it should associate with collections" do
    assert_equal 1, tags(:gameofthrones).collections.count
  end
end