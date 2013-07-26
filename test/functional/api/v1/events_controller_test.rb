require 'test_helper'

class Api::V1::EventsControllerTest < ActionController::TestCase

  setup do
    ENV["API_KEY"]  = nil
    Event.destroy_all
  end

  test "it should create events from list of urls" do
    assert_difference("Event.count", 2) do
      post :create, urls:["http://www.amazon.fr/1","http://www.amazon.fr/1"], tracker:"toto", visitor:"1234", developer:developers(:prixing).api_key, format: :json
    end
    assert_equal developers(:prixing).api_key, cookies[:developer_key]
    
    event = Event.all.first
    assert_equal 0, event.action
    assert_equal developers(:prixing).id, event.developer_id
    assert_equal "0.0.0.0", event.ip_address
    assert_equal "toto", event.tracker
    assert_equal true, event.monetizable
    assert event.device.present?
  end

  test "it should create events from list of urls in GET mode" do
    assert_difference("Event.count", 2) do
      get :index, urls:"http://www.prout.fr/1||http://www.prout.fr/1", tracker:"toto", visitor:"1234", developer:developers(:prixing).api_key
    end
    assert_equal developers(:prixing).api_key, cookies[:developer_key]
    assert_equal ["http://www.prout.fr/1","http://www.prout.fr/1"].to_set, Event.all.map(&:product).map(&:url).to_set
  end

  test "it should create events from list of urls and with action type" do
    assert_difference(["Event.count","Product.count"], 2) do
      post :create, urls:["http://www.amazon.fr/1","http://www.amazon.fr/2"], type:"click", developer:developers(:prixing).api_key, format: :json
    end
    assert_equal 32, cookies[:visitor].length
    event = Event.all.first
    assert_equal 1, event.action
    assert_equal 32, event.device.uuid.length
  end
  
  test "it should ignore events from Googlebot" do
    request.env['HTTP_USER_AGENT'] = "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
    assert_difference("Event.count", 0) do
      post :create, urls:["http://www.amazon.fr/1","http://www.amazon.fr/1"], tracker:"toto", visitor:"1234", developer:developers(:prixing).api_key, format: :json
    end
  end  

end

