require 'test_helper'

class CartHelperTest < ActionView::TestCase

  setup do
    @current_cart = carts(:cart)
    @developer = developers(:shopelia)
    @device = devices(:web)
    @remote_ip = "127.0.0.1"
  end
 
  test "it should generate events for current cart" do
    assert_difference "EventsWorker.jobs.count" do
      generate_requests_for_current_cart
    end

    assert_difference "Event.count", 2 do
      EventsWorker.drain
    end
  end
end