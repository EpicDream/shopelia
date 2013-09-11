require 'test_helper'

class EventTest < ActiveSupport::TestCase

  test "it should create event" do
    event = Event.new(
      :action => Event::VIEW,
      :product_id => products(:headphones).id,
      :device_id => devices(:web).id,
      :developer_id => developers(:prixing).id)
    assert event.save, event.errors.full_messages.join(",")
    assert_equal true, event.monetizable
    assert event.product.present?
  end
  
  test "it should create event from url" do
    assert_difference('Product.count', 1) do
      event = Event.new(
        :action => Event::VIEW,
        :url => "http://www.amazon.fr/my_product",
        :device_id => devices(:web).id,
        :developer_id => developers(:prixing).id)
      assert event.save, event.errors.full_messages.join(",")
    end
  end

  test "it should set false for monetizable if unkown merchant" do
    event = Event.create(
      :action => Event::VIEW,
      :url => "http://www.google.com/my_product",
      :device_id => devices(:web).id,
      :developer_id => developers(:prixing).id)
    assert_equal false, event.monetizable
  end
  
  test "it should create events and products from a list of urls" do
    assert_difference(["Event.count","Product.count"], 2) do
      Event.from_urls(
        :action => Event::VIEW,
        :device_id => devices(:web).id,
        :developer_id => developers(:prixing).id,
        :urls => [ "http://www.amazon.fr/product1", "http://www.amazon.fr/product2" ])
    end
  end

  test "it should skip blank urls" do
    assert_difference(["Event.count","Product.count"], 0) do
      Event.from_urls(
        :action => Event::VIEW,
        :device_id => devices(:web).id,
        :developer_id => developers(:prixing).id,
        :urls => [ "" ])
    end
  end

  test "it shouldn't create event without valid product" do
    event = Event.new(
      :action => Event::CLICK,
      :url => "",
      :device_id => devices(:web).id,
      :developer_id => developers(:prixing).id)
    assert !event.save
  end
end
