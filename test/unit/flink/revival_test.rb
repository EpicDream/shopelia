require 'test_helper'

class RevivalTest < ActiveSupport::TestCase
  
  setup do
    @fanny = flinkers(:fanny)
    @look = looks(:agadir)
  end
  
  test "revive!" do
    now = Time.at(1399274401)
    Time.stubs(:now).returns(now)
    @fanny.update_attributes(last_session_open_at: Time.now - 4.days, last_revival_at: Time.now - 2.weeks)
    
    follow(flinkers(:betty), @fanny)
    like(@fanny, [@look])
    flinkers = Flinker.top_likers_of_publisher_of_look(@look)
    
    NewLooksNotificationWorker.expects(:perform_in).with(23999, @fanny.id, @look.id)
    
    Revival.revive!(flinkers, @look)
    assert @fanny.reload.last_revival_at.between?(now - 4, now)
  end
  
  test "revive! at 10am local zone time today if before 10" do
    now = Time.at(1399274401)
    Time.stubs(:now).returns(now)
    @fanny.update_attributes(last_session_open_at: Time.now - 4.days, last_revival_at: Time.now - 2.weeks)
    
    [["Europe/Paris", 2399], ["America/New_York", 23999]].each do |zone, offset|
      @fanny.timezone = zone
      revival = Revival.new(@fanny, @look)
    
      assert_equal offset, revival.revive_in
    end
  end

  test "revive! at 10am local zone time tomorrow if after 10" do
    now = Time.at(1399326078)
    Time.stubs(:now).returns(now)
    
    [["Europe/Paris", 37122], ["America/New_York", 58722]].each do |zone, offset|
      @fanny.timezone = zone
      revival = Revival.new(@fanny, @look)
      
      assert_equal offset, revival.revive_in
    end
  end
  
  test "dont revive if last open session less than 72h" do
    @fanny.update_attributes(last_session_open_at: Time.now - 2.days, last_revival_at: Time.now - 2.weeks)
    
    NewLooksNotificationWorker.expects(:perform_in).never
    
    Revival.new(@fanny, @look).revive!
  end
  
  test "dont revive if last revive less than 1 week" do
    @fanny.update_attributes(last_session_open_at: Time.now - 8.days, last_revival_at: Time.now - 5.days)
    
    NewLooksNotificationWorker.expects(:perform_in).never
    
    Revival.new(@fanny, @look).revive!
  end
  
end