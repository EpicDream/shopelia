require 'flink/push'

class ApnsNotification < ActiveRecord::Base
  EMAILS_FOR_TESTING = ["olivierfisch@hotmail.com", "anoiaque@gmail.com"]
  attr_accessible *column_names

  def apns_test
    EMAILS_FOR_TESTING.each { |email| 
      flinker = Flinker.where(email:email).first
      Flink::Push.deliver(text_for(flinker), flinker.device)
    }
  end
  
  def send_to_all_flinkers
    Flinker.where("email !~ '@flink'").find_each { |flinker|
      begin
        Flink::Push.deliver(self.text_for(flinker), flinker.device)
      rescue => e
        Rails.logger.error("[APNS_NOTIFICATION_NOT_SENT] #{flinker.id}")
      end
    }
  end
  
  def text_for flinker
    flinker.lang_iso == 'fr_FR' ? text_fr : text_en
  end
  
end