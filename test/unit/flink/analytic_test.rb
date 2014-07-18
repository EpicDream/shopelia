require 'test_helper'

class AnalyticTest < ActiveSupport::TestCase
  
  setup do
    @publisher = flinkers(:betty)
    @publisher.looks.update_all(flink_published_at: Time.now)
    @look = @publisher.looks.first
    populate @look.uuid
  end
  
  test "analytic for publisher" do
    stats = {:followers=>0, :looks=>2, :likes=>2, :comments=>0, :looks_seen=>3, :blog_clicks=>1, :see_all=>2}
    
    analytic = Analytic::Publisher.new(@publisher)
    
    assert_equal stats, analytic.statistics
  end
  
  private
  
  def populate look_uuid
    ["clickblog", "seeall", "seelook"].each_with_index do |event, idx|
      (idx + 1).times { Tracking.create(event: event, publisher_id: @publisher.id, look_uuid: look_uuid)}
    end
  end
  
end