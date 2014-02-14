require 'test_helper'
require 'flink/notification'

class Flink::NotificationTest < ActiveSupport::TestCase
  
  test "follow notification message" do
    flinker = flinkers(:betty)
    follower = flinkers(:lilou)
    
    
    ["fr", "en-US", "en-GB", "it", "de", "es"].each do |lang|
      flinker.update_attributes!(lang_iso:lang)
      notif = Flink::FollowNotification.new(flinker, follower)
      
      assert_equal follow_message_for(flinker), notif.message, "Failure for #{lang}"
    end
  end
  
  test "deliver message should call APN with message and flinker device token" do
    flinker = flinkers(:betty)
    follower = flinkers(:lilou)
    devices(:mobile).update_attributes(flinker_id:flinker.id)
    
    APNS.expects(:send_notification).with(flinker.device.push_token, alert:'Lilou te suit!')
    
    Flink::FollowNotification.new(flinker, follower).deliver
  end
  
  test "default translation is in english en-GB locale" do
    flinker = flinkers(:nana)
    follower = flinkers(:lilou)
    devices(:mobile).update_attributes(flinker_id:flinker.id)
    
    APNS.expects(:send_notification).with(flinker.device.push_token, alert:'Lilou is following you!')
    
    Flink::FollowNotification.new(flinker, follower).deliver
  end
  
  private
  
  def follow_message_for flinker
    case flinker.lang_iso
    when 'fr' then return "Lilou te suit!"
    when 'es' then return "Lilou te siga!"
    when 'it' then return "Lilou ti segue!"
    when 'de' then return "Lilou folgt Ihnen!"
    when 'en-US' then return "Lilou is following you!"
    when 'en-GB' then return "Lilou is following you!"
    end  
  end
  
end