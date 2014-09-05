require 'flink/push'

class ApnsNotification < ActiveRecord::Base
  TARGETS = ["Look", "Flinker", "Hashtag", "Theme"]
  
  def apns_test
    devices = Device.where(flinker_id: Flinker.where(email: Rails.configuration.emails_for_testing).map(&:id))
    Flink::Push.deliver_by_batch(text_fr, devices, metadata)
    Flink::Push.deliver_by_batch(text_en, devices, metadata)
  end
  
  def send_to_all_flinkers
    ApnsNotificationWorker.perform_async(text_fr, :fr, metadata)
    ApnsNotificationWorker.perform_async(text_en, :en, metadata)
  end
  
  private
  
  def metadata
    return {} if self.resource_klass_name.nil?
    { "link_kind" => link_kind , "identifier" => identifier }
  end
  
  def link_kind
    "#{self.resource_klass_name.downcase}s"
  end
  
  def identifier
    case self.resource_klass_name
    when "Look" then Look.find(self.resource_id).uuid
    when "Flinker" then self.resource_id.to_s
    when "Hashtag" then Hashtag.find(self.resource_id).name
    when "Theme" then nil
    end
  end
  
end