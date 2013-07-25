require 'test_helper'

class IncidentTest < ActiveSupport::TestCase
  
  test "it should create incident" do
    incident = Incident.new(
      :issue => "Viking",
      :severity => Incident::CRITICAL,
      :description => "Viking is down")
    assert incident.save
  end
end
