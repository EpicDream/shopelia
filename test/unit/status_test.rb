require 'test_helper'

class StatusTest < ActiveSupport::TestCase

  test "it should create status" do
    status = Status.new(:name => "example")
    assert status.save, status.errors.full_messages.join(",")
  end
  
end
