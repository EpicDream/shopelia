# -*- encoding : utf-8 -*-
require 'test_helper'

class Api::V1::Products::RequestsControllerTest < ActionController::TestCase
  
  setup do
    Event.destroy_all
  end

  test "it should create events from list of urls" do
    assert_difference("EventsWorker.jobs.count", 2) do
      post :create, urls:["http://www.amazon.fr/1/é","http://www.amazon.fr/2"], format: :json
    end
    
    assert_difference("Event.count", 2) do
      EventsWorker.drain
    end

    event = Event.all.first
    assert_equal Event::REQUEST, event.action
    assert_equal "0.0.0.0", event.ip_address
    assert_equal nil, event.tracker
    assert_equal true, event.monetizable
    assert event.device.nil?

    assert_equal ["http://www.amazon.fr/1/e","http://www.amazon.fr/2"].to_set, Event.all.map(&:product).map(&:url).to_set
  end
end