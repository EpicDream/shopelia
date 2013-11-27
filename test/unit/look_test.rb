require 'test_helper'

class LookTest < ActiveSupport::TestCase

  setup do
    @flinker = flinkers(:betty)
  end

  test "it should create look" do
    look = Look.new(
      name:"Article",
      flinker_id:@flinker.id,
      published_at:Time.now,
      url:"http://www.leblogdebetty.com/article")
    assert look.save
  end
end