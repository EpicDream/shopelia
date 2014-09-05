require 'flink/push'

class ApnsNotification < ActiveRecord::Base
  TARGETS = ["Look", "Flinker", "Hashtag", "Theme"]
  
  before_save :find_resource_id, unless: -> { self.resource_identifier.blank? }
  
  def apns_test
    devices = Device.where(flinker_id: Flinker.where(email: Rails.configuration.emails_for_testing).map(&:id))
    devices.each do |device|
      [text_fr, text_en].each { |text| Flink::Push.deliver(text, device, metadata) }
    end
  end
  
  def send_to_all_flinkers
    ApnsNotificationWorker.perform_async(text_fr, :fr, metadata)
    ApnsNotificationWorker.perform_async(text_en, :en, metadata)
  end
  
  private
  
  def metadata
    return { "notification_id" => self.id.to_s } if self.resource_klass_name.blank?
    { "link_kind" => link_kind , "identifier" => identifier, "notification_id" => self.id.to_s }
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
  
  def find_resource_id
    self.resource_id = case self.resource_klass_name
    when "Look" then Look.with_uuid(self.resource_identifier).first.id
    when "Hashtag" then Hashtag.find_or_create_by_name(self.resource_identifier).id
    when "Flinker" then Flinker.find(self.resource_identifier).id
    when "Theme" then nil
    end
  end
  
end