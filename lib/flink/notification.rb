require 'flink/push'

module Flink
  class Notification
    attr_accessor :message, :flinker
    
    def deliver
      Flink::Push.deliver(message, flinker.device)
    end
  end
end

class Flink::FollowNotification < Flink::Notification
  
  def initialize flinker, follower
    @flinker = flinker
    @follower = follower
  end
  
  def message
    I18n.t("flink.notification.follow", username:@follower.username, :locale => @flinker.lang_iso)
  end
  
end