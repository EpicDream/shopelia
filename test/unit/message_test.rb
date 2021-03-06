require 'test_helper'

class MessageTest < ActiveSupport::TestCase

  setup do
    @device = devices(:mobile)
  end

  test "it should create message" do
    message = Message.new(content:"allo",device_id:@device.id)
    assert message.save, message.errors.full_messages.join("\n")
    assert_equal "allo", message.content
    assert message.rating.nil?
  end

  test "it should create message from user even without push token" do 
    @device.update_attribute :push_token, nil    
    message = Message.new(content:"allo",device_id:@device.id)
    assert message.save
  end

  test "it shouldn't create message from admin without push token" do 
    @device.update_attribute :push_token, nil    
    message = Message.new(content:"allo",device_id:@device.id, from_admin:true)
    assert !message.save
  end

  test "it should create message with data only" do
    message = Message.new(products_urls:"http://www.amazon.fr",device_id:@device.id)
    assert message.save, message.errors.full_messages.join("\n")
  end

  test "it should serialize products_urls and create events" do
    products_urls = "http://www.toto.com\nhttp://www.titi.com"
    assert_difference "EventsWorker.jobs.count", 2 do
      message = Message.new(content:"allo",products_urls:products_urls,device_id:@device.id)
      assert message.save, message.errors.full_messages.join("\n")
      assert_equal [ "http://www.toto.com", "http://www.titi.com" ], message.data
    end
  end

  test "it should open and close conversations" do
    @device.update_attribute :pending_answer, false
    Message.create(content:"allo",device_id:@device.id)
    assert @device.reload.pending_answer
    Message.create(content:"allo",device_id:@device.id,from_admin:true)
    assert !@device.reload.pending_answer
  end

  test "it shouldn't set autoreplied to false when Georges receives a new message" do
    @device.update_attribute :autoreplied, true
    Message.create(content:"allo",device_id:@device.id)
    assert @device.reload.autoreplied
  end

  test "it shouldn't set autoreplied to false when Georges replies" do
    @device.update_attribute :autoreplied, true
    Message.create(content:"allo",device_id:@device.id,from_admin:true)
    assert @device.reload.autoreplied
  end

  test "it should send message to admin when user writes to Georges" do
    Message.create(content:"allo",device_id:@device.id)
    assert_equal 1, ActionMailer::Base.deliveries.count
    assert_equal "georges@shopelia.fr", ActionMailer::Base.deliveries.first.to[0]
    assert_equal 0, $push_delivery_count
  end

  test "it should push device when Georges writes back to user" do
    assert_difference "$push_delivery_count" do
      Message.create(content:"allo",device_id:@device.id,from_admin:true)
    end
  end

  test "it should build push data content" do
    products_urls = "http://www.amazon.com\nhttp://www.amazon.fr"
    message = Message.create(content:"allo",products_urls:products_urls,device_id:@device.id)
    data = message.build_push_data
    assert_equal 2, data.count
    assert_equal ["http://www.amazon.com","http://www.amazon.fr"].to_set, data.map{|e| e[:product_url]}.to_set
  end

  test "it should send rating card" do
    message = Message.new(device_id:@device.id,rating_card:1,from_admin:true)
    assert message.save
    assert_equal 0, message.rating
  end

  test "it should update device with rating" do 
    m = Message.create(device_id:@device.id,rating_card:1,from_admin:true)
    message = Message.find(m.id)
    message.update_attribute :rating, 5
    assert_equal 5, message.reload.rating
    assert_equal 5, @device.reload.rating
  end

  test "it should autoreply when updating with rating" do
    assert_difference "$push_delivery_count", 2 do
      m = Message.create(device_id:@device.id,rating_card:1,from_admin:true)
      message = Message.find(m.id)
      message.update_attribute :rating, 1
    end
  end
end