require 'test_helper'
require 'flink/notification'

class Flink::NotificationTest < ActiveSupport::TestCase
  
  test "follow notification message" do
    flinker = flinkers(:betty)
    follower = flinkers(:lilou)
    
    [:france, :angleterre, :italy, :"united-states", :spain, :allemagne].each do |country|
      flinker.update_attributes!(country_id:countries(country).id)
      notif = Flink::FollowNotification.new(flinker, follower)
      
      assert_equal follow_message_for(flinker), notif.message, "Failure for #{country}"
    end
  end
  
  test "deliver message should call APN with message and flinker device token" do
    flinker = flinkers(:betty)
    follower = flinkers(:lilou)
    devices(:mobile).update_attributes(flinker_id:flinker.id)
    
    APNS.expects(:send_notification).with(flinker.device.push_token, alert:'Lilou te suit!')
    
    Flink::FollowNotification.new(flinker, follower).deliver
  end
  
  private
  
  def follow_message_for flinker
    case flinker.country.iso
    when 'FR' then return "Lilou te suit!"
    when 'ES' then return "Lilou te siga!"
    when 'IT' then return "Lilou ti segue!"
    when 'DE' then return "Lilou folgt Ihnen!"
    when 'US' then return "Lilou is following you!"
    when 'GB' then return "Lilou is following you!"
    end  
  end
  
end