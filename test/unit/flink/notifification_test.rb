require 'test_helper'
require 'flink/notification'

class Flink::NotificationTest < ActiveSupport::TestCase
  
  test "follow notification message" do
    flinker = flinkers(:betty)
    follower = flinkers(:lilou)
    
    ["fr_FR", "en_US", "en_GB", "it_IT", "de_DE", "es_ES"].each do |lang|
      flinker.update_attributes!(lang_iso:lang)
      notif = Flink::FollowNotification.new(flinker, follower)
      
      assert_equal follow_message_for(flinker), notif.message, "Failure for #{lang}"
    end
  end
  
  test "deliver message should call APN with message and flinker device token" do
    flinker = flinkers(:betty)
    follower = flinkers(:lilou)
    devices(:mobile).update_attributes(flinker_id:flinker.id)
    
    APNS.expects(:send_notification).with(flinker.device.push_token, alert:'@Lilou te suit!', :"content-available" => 1, sound: 'default')
    
    Flink::FollowNotification.new(flinker, follower).deliver
  end
  
  test "missing translation is in english en_GB" do
    flinker = flinkers(:nana)
    flinker.update_attributes!(lang_iso:"unknown")
    follower = flinkers(:lilou)
    devices(:mobile).update_attributes(flinker_id:flinker.id)
    
    APNS.expects(:send_notification).with(flinker.device.push_token, alert:'@Lilou is following you!', :"content-available" => 1, sound: 'default')
    
    Flink::FollowNotification.new(flinker, follower).deliver
  end
  
  test "mention notification message" do
    flinker = flinkers(:betty)
    mentionner = flinkers(:lilou)
    
    ["fr_FR", "en_US", "en_GB", "it_IT", "de_DE", "es_ES"].each do |lang|
      flinker.update_attributes!(lang_iso:lang)
      notif = Flink::MentionNotification.new(flinker, mentionner)
      
      assert_equal mention_message_for(flinker), notif.message, "Failure for #{lang}"
    end
  end
  
  test "signup notification message" do
    flinker = flinkers(:betty)
    signed_up = flinkers(:lilou)
    
    ["fr_FR", "en_US", "en_GB", "it_IT", "de_DE", "es_ES"].each do |lang|
      flinker.update_attributes!(lang_iso:lang)
      notif = Flink::SignupNotification.new(flinker, signed_up)
      
      assert_equal signup_message_for(flinker), notif.message, "Failure for #{lang}"
    end
  end
  
  private
  
  def follow_message_for flinker
    case flinker.lang_iso
    when 'fr_FR' then return "@Lilou te suit!"
    when 'es_ES' then return "@Lilou te siga!"
    when 'it_IT' then return "@Lilou ti segue!"
    when 'de_DE' then return "@Lilou folgt Ihnen!"
    when 'en_US' then return "@Lilou is following you!"
    when 'en_GB' then return "@Lilou is following you!"
    end  
  end
  
  def signup_message_for flinker
    case flinker.lang_iso
    when 'fr_FR' then return "Ton amie facebook @Lilou a rejoint Flink"
    when 'es_ES' then return "Su amigo del facebook @Lilou ha unido Flink"
    when 'it_IT' then return "Il tuo amico facebook @Lilou ha aderito Flink"
    when 'de_DE' then return "Ihr Facebook-Freund @Lilou hat Flink beigetreten"
    when 'en_US' then return "Your facebook friend @Lilou has joined Flink"
    when 'en_GB' then return "Your facebook friend @Lilou has joined Flink"
    end  
  end
  
  def mention_message_for flinker
    case flinker.lang_iso
    when 'fr_FR' then return "Tu as été mentionnée par @Lilou"
    when 'es_ES' then return "Usted fue mencionado por @Lilou"
    when 'it_IT' then return "Lei è stato citato da @Lilou"
    when 'de_DE' then return "Sie wurden von @Lilou erwähnt"
    when 'en_US' then return "You were mentioned by @Lilou"
    when 'en_GB' then return "You were mentioned by @Lilou"
    end  
  end
  
end