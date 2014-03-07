require 'flink/push'

module Flink
  class Notification
    attr_accessor :message, :flinker
    
    def deliver
      Flink::Push.deliver(message, flinker.device) if flinker.device
    end
  end
end

class Flink::FollowNotification < Flink::Notification
  
  def initialize flinker, follower
    @flinker = flinker
    @follower = follower
  end
  
  def message
    begin
      I18n.translate!("flink.notification.follow", username:@follower.username, :locale => @flinker.lang_iso, raise:true)
    rescue I18n::MissingTranslationData
      I18n.translate!("flink.notification.follow", username:@follower.username, :locale => "en_GB", raise:true)
    end
  end
  
end

class Flink::MentionNotification < Flink::Notification
  
  def initialize flinker, mentionner
    @flinker = flinker
    @mentionner = mentionner
  end
  
  def message
    begin
      I18n.translate!("flink.notification.mention", username:@mentionner.username, :locale => @flinker.lang_iso, raise:true)
    rescue I18n::MissingTranslationData
      I18n.translate!("flink.notification.mention", username:@mentionner.username, :locale => "en-GB", raise:true)
    end
  end
  
end

class Flink::SignupNotification < Flink::Notification
  
  def initialize flinker, signed_up
    @flinker = flinker
    @signed_up = signed_up
  end
  
  def message
    begin
      I18n.translate!("flink.notification.signup", username:@signed_up.username, :locale => @flinker.lang_iso, raise:true)
    rescue I18n::MissingTranslationData
      I18n.translate!("flink.notification.signup", username:@signed_up.username, :locale => "en_GB", raise:true)
    end
  end
  
end