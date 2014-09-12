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
    
    APNS.expects(:send_notification).with(flinker.device.push_token, alert:'@Lilou te suit!', :"content-available" => 1, sound: 'default', other: {metadata:{}})
    
    Flink::FollowNotification.new(flinker, follower).deliver
  end
  
  test "missing translation is in english en_GB" do
    flinker = flinkers(:nana)
    flinker.update_attributes!(lang_iso:"unknown")
    follower = flinkers(:lilou)
    devices(:mobile).update_attributes(flinker_id:flinker.id)
    
    APNS.expects(:send_notification).with(flinker.device.push_token, alert:'@Lilou is following you!', :"content-available" => 1, sound: 'default', other: {metadata:{}})
    
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
  
  test "new looks notification" do
    flinker = flinkers(:lilou)
    look = looks(:agadir)
    
    ["fr_FR", "en_US", "en_GB", "it_IT", "de_DE", "es_ES"].each do |lang|
      flinker.update_attributes!(lang_iso:lang)
      notif = Flink::NewLooksNotification.new(flinker, look)
      
      assert_equal new_looks_message_for(flinker), notif.message, "Failure for #{lang}"
    end
  end
  
  test "private message notification" do
    flinker = flinkers(:lilou)
    sender = flinkers(:fanny)
    
    ["fr_FR", "en_US", "en_GB", "it_IT", "de_DE", "es_ES"].each do |lang|
      flinker.update_attributes!(lang_iso:lang)
      notif = Flink::PrivateMessageNotification.new(flinker, sender)
      
      assert_equal private_message_message_for(flinker), notif.message, "Failure for #{lang}"
    end
  end
  
  test "private message answer notification" do
    flinker = flinkers(:lilou)
    sender = flinkers(:fanny)
    
    ["fr_FR", "en_US", "en_GB", "it_IT", "de_DE", "es_ES"].each do |lang|
      flinker.update_attributes!(lang_iso:lang)
      notif = Flink::PrivateMessageAnswerNotification.new(flinker, sender)
      
      assert_equal private_message_answer_message_for(flinker), notif.message, "Failure for #{lang}"
    end
  end
  
  private
  
  def follow_message_for flinker
    case flinker.lang_iso
    when 'fr_FR' then return "@Lilou te suit!"
    when 'es_ES' then return "@Lilou is following you!"
    when 'it_IT' then return "@Lilou is following you!"
    when 'de_DE' then return "@Lilou is following you!"
    when 'en_US' then return "@Lilou is following you!"
    when 'en_GB' then return "@Lilou is following you!"
    end  
  end
  
  def signup_message_for flinker
    case flinker.lang_iso
    when 'fr_FR' then return "Ton amie facebook LilouName a rejoint Flink"
    when 'es_ES' then return "Your facebook friend LilouName has joined Flink"
    when 'it_IT' then return "Your facebook friend LilouName has joined Flink"
    when 'de_DE' then return "Your facebook friend LilouName has joined Flink"
    when 'en_US' then return "Your facebook friend LilouName has joined Flink"
    when 'en_GB' then return "Your facebook friend LilouName has joined Flink"
    end  
  end
  
  def mention_message_for flinker
    case flinker.lang_iso
    when 'fr_FR' then return "Tu as été mentionnée par @Lilou"
    when 'es_ES' then return "You were mentioned by @Lilou"
    when 'it_IT' then return "You were mentioned by @Lilou"
    when 'de_DE' then return "You were mentioned by @Lilou"
    when 'en_US' then return "You were mentioned by @Lilou"
    when 'en_GB' then return "You were mentioned by @Lilou"
    end  
  end
  
  def new_looks_message_for flinker
    case flinker.lang_iso
    when 'fr_FR' then return "@Betty a publié un nouveau look : Agadir"
    when 'es_ES' then return "@Betty has released a new look : Agadir"
    when 'it_IT' then return "@Betty has released a new look : Agadir"
    when 'de_DE' then return "@Betty has released a new look : Agadir"
    when 'en_US' then return "@Betty has released a new look : Agadir"
    when 'en_GB' then return "@Betty has released a new look : Agadir"
    end  
  end
  
  def private_message_message_for flinker
    case flinker.lang_iso
    when 'fr_FR' then return "@fanny vous a envoyé un look"
    else return "@fanny sent you a look"
    end
  end
  
  def private_message_answer_message_for flinker
    case flinker.lang_iso
    when 'fr_FR' then return "@fanny a répondu à votre message"
    else return "@fanny answered your message"
    end
  end
  
  
end