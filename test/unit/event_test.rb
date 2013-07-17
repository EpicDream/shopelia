require 'test_helper'

class EventTest < ActiveSupport::TestCase
  fixtures :products, :developers

  test "it should create event" do
    event = Event.new(
      :action => Event::VIEW,
      :product_id => products(:headphones).id,
      :developer_id => developers(:prixing).id)
    assert event.save, event.errors.full_messages.join(",")
  end
  
  test "it should create event from url" do
    assert_difference('Product.count', 1) do
      event = Event.new(
        :action => Event::VIEW,
        :url => "http://www.amazon.fr/my_product",
        :developer_id => developers(:prixing).id)
      assert event.save, event.errors.full_messages.join(",")
    end
  end
  
  test "it should create events from a list of urls" do
    assert_difference('Event.count', 2) do
      Event.from_urls(
        :action => Event::VIEW,
        :developer_id => developers(:prixing).id,
        :urls => [ "http://www.amazon.fr/product1", "http://www.amazon.fr/product2" ])
    end
  end
end
