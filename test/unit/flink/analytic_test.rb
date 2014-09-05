require 'test_helper'

class AnalyticTest < ActiveSupport::TestCase
  
  setup do
    @publisher = flinkers(:betty)
    @publisher.looks.update_all(flink_published_at: Time.now)
    @look = @publisher.looks.first
    populate @look.uuid
  end
  
  test "analytic for publisher" do
    start_date = Time.now - 2.days
    end_date = Time.now
    stats = {followers:0, looks:2, likes:2, comments:1, looks_seen:3, blog_clicks:1, see_all:2, start_date:start_date.to_i, end_date:end_date.to_i}
    
    analytic = Analytic::Publisher.new(@publisher, start_date, end_date)
    
    assert_equal stats, analytic.statistics
  end
  
  test "stats for n last weeks" do
    stats = Analytic::Publisher.statistics(@publisher)
    
    assert_equal 5, stats.count
    assert_equal 2, stats.first[:looks]
    assert_equal 3, stats.first[:looks_seen]
  end
  
  test "analytic for look" do
    start_date = Time.now - 2.days
    end_date = Time.now
    stats = {views:3, likes:2, comments:1, blog_clicks:1, see_all:2, start_date:start_date.to_i, end_date:end_date.to_i}
    
    analytic = Analytic::Look.new(@look, start_date, end_date)

    assert_equal stats, analytic.statistics
  end
  
  test "look stats for n last weeks" do
    stats = Analytic::Look.statistics(@look)
    
    assert_equal 5, stats.count
    assert_equal 3, stats.first[:views]
    assert_equal 2, stats.first[:see_all]
  end
  
  
  private
  
  def populate look_uuid
    ["clickblog", "seeall", "seelook"].each_with_index do |event, idx|
      (idx + 1).times { Tracking.create(event: event, publisher_id: @publisher.id, look_uuid: look_uuid)}
    end
  end
  
end