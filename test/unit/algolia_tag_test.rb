require 'test_helper'

class AlgoliaTagTest < ActiveSupport::TestCase

  test "it should create tags" do
    tag = AlgoliaTag.new(name:"toto",kind:"brand",count:100)
    assert tag.save
    assert_equal "toto", tag.name
    assert_equal "brand", tag.kind
    assert_equal 100, tag.count
  end
end