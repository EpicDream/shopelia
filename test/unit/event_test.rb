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

  test "it should skip bad urls" do
    assert_difference(["Event.count","Product.count"], 0) do
      Event.from_urls(
        :action => Event::VIEW,
        :device_id => devices(:web).id,
        :developer_id => developers(:prixing).id,
        :urls => [ "", " ", "/product", "none" ])
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

  test "it shouldn't reset viking_sent_at if product versions are not expired when event is created" do
    p = products(:headphones)
    p.update_attributes(
      versions_expires_at:1.hour.from_now,
      viking_sent_at:3.hours.ago)
    event = Event.create!(
      :action => Event::VIEW,
      :product_id => p.id,
      :device_id => devices(:web).id,
      :developer_id => developers(:prixing).id)

    assert_not_nil p.reload.viking_sent_at
  end

  test "it should reset viking_sent_at if product versions are expired when event is created" do
    p = products(:headphones)
    p.update_attributes(
      versions_expires_at:1.hour.ago,
      viking_sent_at:1.hours.ago)
    event = Event.create!(
      :action => Event::VIEW,
      :product_id => p.id,
      :device_id => devices(:web).id,
      :developer_id => developers(:prixing).id)

    assert p.reload.viking_sent_at.nil?
  end  
end