require 'test_helper'
require 'flink/notification'

class Flink::NotificationTest < ActiveSupport::TestCase
  
  test "follow notification message" do
    flinker = flinkers(:betty)
    follower = flinkers(:lilou)
    
    ["fr-FR", "en-US", "en-GB", "it", "de", "es"].each do |lang|
      flinker.update_attributes!(lang_iso:lang)
      notif = Flink::FollowNotification.new(flinker, follower)
      
      assert_equal follow_message_for(flinker), notif.message, "Failure for #{lang}"
    end
  end
  
  test "deliver message should call APN with message and flinker device token" do
    flinker = flinkers(:betty)
    follower = flinkers(:lilou)
    devices(:mobile).update_attributes(flinker_id:flinker.id)
    
    APNS.expects(:send_notification).with(flinker.device.push_token, alert:'Lilou te suit!', :"content-available" => 1)
    
    Flink::FollowNotification.new(flinker, follower).deliver
  end
  
  test "missing translation is in english en-GB" do
    flinker = flinkers(:nana)
    flinker.update_attributes!(lang_iso:"unknown")
    follower = flinkers(:lilou)
    devices(:mobile).update_attributes(flinker_id:flinker.id)
    
    APNS.expects(:send_notification).with(flinker.device.push_token, alert:'Lilou is following you!', :"content-available" => 1)
    
    Flink::FollowNotification.new(flinker, follower).deliver
  end
  
  test "mention notification message" do
    flinker = flinkers(:betty)
    mentionner = flinkers(:lilou)
    
    ["fr-FR", "en-US", "en-GB", "it", "de", "es"].each do |lang|
      flinker.update_attributes!(lang_iso:lang)
      notif = Flink::MentionNotification.new(flinker, mentionner)
      
      assert_equal mention_message_for(flinker), notif.message, "Failure for #{lang}"
    end
  end
  
  test "signup notification message" do
    flinker = flinkers(:betty)
    signed_up = flinkers(:lilou)
    
    ["fr-FR", "en-US", "en-GB", "it", "de", "es"].each do |lang|
      flinker.update_attributes!(lang_iso:lang)
      notif = Flink::SignupNotification.new(flinker, signed_up)
      
      assert_equal signup_message_for(flinker), notif.message, "Failure for #{lang}"
    end
  end
  
  private
  
  def follow_message_for flinker
    case flinker.lang_iso
    when 'fr-FR' then return "Lilou te suit!"
    when 'es' then return "Lilou te siga!"
    when 'it' then return "Lilou ti segue!"
    when 'de' then return "Lilou folgt Ihnen!"
    when 'en-US' then return "Lilou is following you!"
    when 'en-GB' then return "Lilou is following you!"
    end  
  end
  
  def signup_message_for flinker
    case flinker.lang_iso
    when 'fr-FR' then return "Ton amie facebook @Lilou a rejoint Flink"
    when 'es' then return "Su amigo del facebook @Lilou ha unido Flink"
    when 'it' then return "Il tuo amico facebook @Lilou ha aderito Flink"
    when 'de' then return "Ihr Facebook-Freund @Lilou hat Flink beigetreten"
    when 'en-US' then return "Your facebook friend @Lilou has joined Flink"
    when 'en-GB' then return "Your facebook friend @Lilou has joined Flink"
    end  
  end
  
  def mention_message_for flinker
    case flinker.lang_iso
    when 'fr-FR' then return "Tu as été mentionnée par @Lilou"
    when 'es' then return "Usted fue mencionado por @Lilou"
    when 'it' then return "Lei è stato citato da @Lilou"
    when 'de' then return "Sie wurden von @Lilou erwähnt"
    when 'en-US' then return "You were mentioned by @Lilou"
    when 'en-GB' then return "You were mentioned by @Lilou"
    end  
  end
  
end