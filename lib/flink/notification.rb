require_relative 'push'

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
    @fb_signed_up = FacebookFriend.where(flinker_id:@signed_up.id).first
  end
  
  def message
    begin
      I18n.translate!("flink.notification.signup", username:@fb_signed_up.name, :locale => @flinker.lang_iso, raise:true)
    rescue I18n::MissingTranslationData
      I18n.translate!("flink.notification.signup", username:@fb_signed_up.name, :locale => "en_GB", raise:true)
    end
  end
  
end

class Flink::NewLooksNotification < Flink::Notification
  
  def initialize flinker, look
    @flinker = flinker
    @look = look
    @publisher = look.flinker
  end
  
  def message
    begin
      I18n.translate!(
        "flink.notification.new_looks", 
        username: @publisher.name,
        look_name: @look.name,
        locale: @flinker.lang_iso, 
        raise:true
      )
    rescue I18n::MissingTranslationData
      I18n.translate!(
        "flink.notification.new_looks", 
        username: @publisher.name, 
        look_name: @look.name,
        locale: "en_GB", 
        raise:true
      )
    end
  end
  
end

class Flink::PrivateMessageNotification < Flink::Notification

  def initialize flinker, sender
    @flinker = flinker
    @sender = sender
  end
  
  def message
    begin
      I18n.translate!("flink.notification.private_message", username:@sender.username, :locale => @flinker.lang_iso, raise:true)
    rescue I18n::MissingTranslationData
      I18n.translate!("flink.notification.private_message", username:@sender.username, :locale => "en_GB", raise:true)
    end
  end
  
end

class Flink::PrivateMessageAnswerNotification < Flink::Notification
  
  def initialize flinker, sender
    @flinker = flinker
    @sender = sender
  end
  
  def message
    begin
      I18n.translate!("flink.notification.private_message_answer", username:@sender.username, :locale => @flinker.lang_iso, raise:true)
    rescue I18n::MissingTranslationData
      I18n.translate!("flink.notification.private_message_answer", username:@sender.username, :locale => "en_GB", raise:true)
    end
  end
  
end
