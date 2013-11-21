require 'test_helper'

class Api::Showcase::Products::SearchControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  test "it should answer to ean search" do
    jobs = EventsWorker.jobs.count
    get :index, ean:"9782749910116", visitor:"uuid", format: :json
    
    assert_response :success
    assert json_response["name"].present?
    assert EventsWorker.jobs.count > jobs

    events = Event.count
    EventsWorker.drain

    assert Event.count > events
  end

  test "it should generate scan log" do
    assert_difference "ScanLog.count" do
      get :index, ean:"9782749910116", visitor:"uuid", format: :json
    end
  end
end