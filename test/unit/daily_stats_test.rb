require 'test_helper'

class EventTest < ActiveSupport::TestCase

  setup do
    meta_orders(:elarch_billing).destroy # cleanup
    @developer = developers(:prixing)
    @date = Date.parse("2013-08-15")
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
    assert_equal 1, @stats.daily_orders
  end

  test "it should count monthly completed orders" do
    assert_equal 2, @stats.monthly_orders
  end

  test "it should count daily signups" do
    assert_equal 4, @stats.daily_signups
  end

  test "it should count monthly signups" do
    assert_equal 4, @stats.monthly_signups
  end
  
  test "it should count daily unique views" do
    assert_equal 1, @stats.daily_unique_views
  end

  test "it should count daily unique clicks" do
    assert_equal 1, @stats.daily_unique_clicks
  end

  test "it should count monthly unique views" do
    assert_equal 2, @stats.monthly_unique_views
  end

  test "it should count monthly unique clicks" do
    assert_equal 2, @stats.monthly_unique_clicks
  end
  
  test "it should generate two rankings" do
    assert_equal 4, @stats.rankings.count
  end
  
  test "it should generate merchant daily ranking" do
    ranking = @stats.rankings[0]
    assert_equal "Top daily merchants", ranking[:name]
    data = ranking[:data]
    assert_equal 1, data.count
    assert_equal "Amazon", data[0][:name]
    assert_equal 2, data[0][:views]
    assert_equal 1, data[0][:clicks]
  end

  test "it should generate merchant monthly ranking" do
    ranking = @stats.rankings[1]
    assert_equal "Top monthly merchants", ranking[:name]
    data = ranking[:data]
    assert_equal 1, data.count
    assert_equal "Amazon", data[0][:name]
    assert_equal 4, data[0][:views]
    assert_equal 2, data[0][:clicks]
  end

  test "it should generate developer daily ranking" do
    ranking = @stats.rankings[2]
    assert_equal "Top daily developers", ranking[:name]
    data = ranking[:data]
    assert_equal 1, data.count
    assert_equal "Prixing", data[0][:name]
    assert_equal 2, data[0][:views]
    assert_equal 1, data[0][:clicks]
  end

  test "it should generate developer monthly ranking" do
    ranking = @stats.rankings[3]
    assert_equal "Top monthly developers", ranking[:name]
    data = ranking[:data]
    assert_equal 1, data.count
    assert_equal "Prixing", data[0][:name]
    assert_equal 4, data[0][:views]
    assert_equal 2, data[0][:clicks]
  end
  
  test "it should send email" do
    @stats.send_email
    mail = ActionMailer::Base.deliveries.last
    assert mail.present?, "a stats email should have been sent"
  end
  
  private
  
  def populate_data
    [ "http://www.amazon.fr/productA", "http://www.amazon.fr/productB" ].each do |url|
      Event.create(
        :url => url,
        :action => Event::VIEW,
        :device_id => devices(:web).id,
        :developer_id => @developer.id)
    end
    Event.create(
      :url => "http://www.amazon.fr/productA",
      :action => Event::CLICK,
      :device_id => devices(:web).id,
      :developer_id => @developer.id)
    Event.update_all "created_at='2013-08-01 10:00'"
    [ "http://www.amazon.fr/productA", "http://www.amazon.fr/productB" ].each do |url|
      Event.create(
        :url => url,
        :action => Event::VIEW,
        :device_id => devices(:mobile).id,
        :developer_id => @developer.id)
    end
    Event.create(
      :url => "http://www.amazon.fr/productA",
      :device_id => devices(:mobile).id,
      :action => Event::CLICK,
      :developer_id => @developer.id)
    Event.where("created_at > '2013-08-02'").update_all "created_at='2013-08-15 10:00'"
    Order.order(:created_at).first.update_attribute :created_at, '2013-08-01 10:00'
    Order.order(:created_at).second.update_attribute :created_at, '2013-08-15 10:00'
    Order.order(:created_at).second.update_attribute :state_name, "completed"
    User.update_all "created_at='2013-08-15 10:00'"
  end
end
