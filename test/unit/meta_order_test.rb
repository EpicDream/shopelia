require 'test_helper'

class MetaOrderTest < ActiveSupport::TestCase

  test "it should create meta order" do 
    meta = MetaOrder.new(user_id:users(:elarch).id)
    assert meta.save, meta.errors.full_messages.join(",")
  end
end
