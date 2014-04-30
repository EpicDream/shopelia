require 'test_helper'

class RevivalTest < ActiveSupport::TestCase
  
  setup do
    @fanny = flinkers(:fanny)
    @look = looks(:agadir)
  end
  
  test "revive!" do
    follow(flinkers(:betty), @fanny)
    like(@fanny, [@look])
    flinkers = Flinker.top_likers_of_publisher_of_look(@look)
    
    NewLooksNotificationWorker.expects(:perform_in).with(10.minutes, @fanny.id, @look.id)
    
    Revival.revive!(flinkers, @look)
  end
  
  test "revive! at 10pm local zone time" do
    
  end
  
end