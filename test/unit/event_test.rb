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

  test "it should fail bad urls" do
    assert_difference(["Event.count","Product.count"], 0) do
      event = Event.create(
      :action => Event::VIEW,
      :url => "none",
      :device_id => devices(:web).id,
      :developer_id => developers(:prixing).id)
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

  test "it should filter bots" do
    [ "Python-urllib/2.7",
      "QuerySeekerSpider ( http://queryseeker.com/bot.html )",
      "Mozilla/5.0 (compatible; Kraken/0.1; http://linkfluence.net/; bot@linkfluence.net)",
      "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2) Gecko/20100115 Firefox/3.6 (FlipboardProxy/1.1; +http://flipboard.com/browserproxy)"
    ].each do |ua|
      assert Event.is_bot?(ua), ua
    end
    assert !Event.is_bot?("Mozilla/5.0 (Windows NT 6.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.66 Safari/537.36")
  end 

  test "it should raise exception if merchant doesn't accept events" do
    products(:headphones).merchant.update_attribute :rejecting_events, true
    assert_raise Exceptions::RejectingEventsException do 
      event = Event.create(
        :action => Event::VIEW,
        :product_id => products(:headphones).id,
        :device_id => devices(:web).id,
        :developer_id => developers(:prixing).id)
    end
  end
end