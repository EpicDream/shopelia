require 'test_helper'

class IncidentTest < ActiveSupport::TestCase
  
  test "it should create incident" do
    incident = Incident.new(
      :issue => "Viking",
      :severity => Incident::CRITICAL,
      :description => "Viking is down",
      :resource_type => 'Product',
      :resource_id => nil)
    assert incident.save
    
    assert_equal "Viking", incident.issue
    assert_equal Incident::CRITICAL, incident.severity
    assert_equal "Viking is down", incident.description
    assert_equal "Product", incident.resource_type
  end
end
