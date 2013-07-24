require 'test_helper'

class EventTest < ActiveSupport::TestCase

  setup do
    @developer = developers(:prixing)
    @date = Date.today
    populate_data
    @stats = DailyStats.new(@date)
  end

  test "it should set yesterday's date by default" do
    assert_equal Date.yesterday, DailyStats.new.date
  end

  test "it should set daily active developers" do
    assert_equal 1, @stats.daily_active_developers
  end

  test "it should set monthly active merchants" do
    assert_equal 1, @stats.monthly_active_merchants
  end

  test "it should set monthly active developers" do
    assert_equal 1, @stats.monthly_active_developers
  end

  test "it should set daily active merchants" do
    assert_equal 1, @stats.daily_active_merchants
  end
  
  test "it should set daily button views" do
    assert_equal 2, @stats.daily_views 
  end

  test "it should set daily button clicks" do
    assert_equal 1, @stats.daily_clicks
  end

  test "it should set monthly button views" do
    assert_equal 4, @stats.monthly_views 
  end

  test "it should set monthly button clicks" do
    assert_equal 2, @stats.monthly_clicks
  end
  
  test "it should count daily completed orders" do
    assert_equal 0, @stats.daily_orders
  end

  test "it should count daily montlhy orders" do
    assert_equal 1, @stats.monthly_orders
  end

  test "it should count daily signups" do
    assert_equal 2, @stats.daily_signups
  end

  test "it should count monthly signups" do
    assert_equal 3, @stats.monthly_signups
  end
  
  test "it should generate two rankings" do
    assert_equal 2, @stats.rankings.count
  end
  
  test "it should generate merchant ranking" do
    ranking = @stats.rankings.first
    assert_equal "Top daily merchants", ranking[:name]
    data = ranking[:data]
    assert_equal 1, data.count
    assert_equal "Amazon", data[0][:key]
    assert_equal 2, data[0][:value]
  end

  test "it should generate developer ranking" do
    ranking = @stats.rankings.second
    assert_equal "Top daily developers", ranking[:name]
    data = ranking[:data]
    assert_equal 1, data.count
    assert_equal "Prixing", data[0][:key]
    assert_equal 2, data[0][:value]
  end
  
  test "it should send email" do
    @stats.send_email
    mail = ActionMailer::Base.deliveries.last
    assert mail.present?, "a stats email should have been sent"
  end
  
  private
  
  def populate_data
    Event.from_urls(
      :urls => [ "http://www.amazon.fr/productA", "http://www.amazon.fr/productB" ],
      :action => Event::VIEW,
      :developer_id => @developer.id)
    Event.from_urls(
      :urls => [ "http://www.amazon.fr/productA" ],
      :action => Event::CLICK,
      :developer_id => @developer.id)
    Event.update_all "created_at='#{@date.at_beginning_of_month}'"
    Event.from_urls(
      :urls => [ "http://www.amazon.fr/productA", "http://www.amazon.fr/productB" ],
      :action => Event::VIEW,
      :developer_id => @developer.id)
    Event.from_urls(
      :urls => [ "http://www.amazon.fr/productA" ],
      :action => Event::CLICK,
      :developer_id => @developer.id)
    Order.first.update_attribute :state_name, "completed"
    users(:elarch).update_attribute :created_at, @date.at_beginning_of_month + 1.day
  end
end
