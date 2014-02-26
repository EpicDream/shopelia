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
      I18n.translate!("flink.notification.follow", username:@follower.username, :locale => "en-GB", raise:true)
    end
  end
  
end