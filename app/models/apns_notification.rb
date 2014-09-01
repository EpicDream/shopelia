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
    ApnsNotificationWorker.perform_async(text_fr, :fr)
    ApnsNotificationWorker.perform_async(text_en, :en)
  end
  
  def text_for flinker
    flinker.lang_iso == 'fr_FR' ? text_fr : text_en
  end
  
end