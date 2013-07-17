require 'test_helper'

class Api::V1::EventsControllerTest < ActionController::TestCase
  fixtures :developers

  test "it should create events from list of urls" do
    assert_difference("Event.count", 2) do
      post :create, urls:["http://www.amazon.fr/1","http://www.amazon.fr/1"], tracker:"toto", visitor:"1234", format: :json
    end
    assert_equal developers(:prixing).api_key, cookies[:developer_key]
    
    event = Event.all.first
    assert_equal 0, event.action
    assert_equal "Rails Testing", event.user_agent
    assert_equal developers(:prixing).id, event.developer_id
    assert_equal "0.0.0.0", event.ip_address
    assert_equal "toto", event.tracker
    assert_equal "1234", event.visitor
  end

  test "it should create events from list of urls in GET mode" do
    assert_difference("Event.count", 2) do
      get :index, urls:"http://www.prout.fr/1||http://www.prout.fr/1", tracker:"toto", visitor:"1234", developer:developers(:prixing).api_key
    end
    assert_equal developers(:prixing).api_key, cookies[:developer_key]
    assert_equal ["http://www.prout.fr/1","http://www.prout.fr/1"].to_set, Event.all.map(&:product).map(&:url).to_set
  end

  test "it should create events from list of urls and with action type" do
    assert_difference("Event.count", 2) do
      post :create, urls:["http://www.amazon.fr/1","http://www.amazon.fr/1"], type:"click", format: :json
    end
    assert_equal 32, cookies[:visitor].length
    
    event = Event.all.first
    assert_equal 1, event.action
    assert_equal 32, event.visitor.length
  end

end

