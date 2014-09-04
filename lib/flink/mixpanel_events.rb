require 'csv'

class MixpanelEvents
  def initialize csv_file_path, event
    @event = event
    @csv_file_path = csv_file_path
  end
  
  def integrate
    CSV.foreach(@csv_file_path, "r") do |row|
      begin
        next if row[4].nil? || row[4] =~ /undefined/
        next unless look = Look.with_uuid(row[4]).includes(:flinker).first
        flinker = Flinker.find_by_id(row[1])
        time = Time.at(row[5].to_i)
        tracking = build_tracking_from look, flinker, time
        tracking.mixpanel = true
        tracking.save!
      rescue
        next
      end
    end
  end
  
  def build_tracking_from look, flinker, time
    tracking = Tracking.new(event: @event, look_uuid: look.uuid, created_at: time, updated_at: time)
    publisher = look.flinker

    if flinker
      tracking.publisher_id = publisher.id
      tracking.flinker_id = flinker.id
      tracking.country_iso = flinker.country_iso
      tracking.lang_iso = flinker.lang_iso
      tracking.timezone = flinker.timezone
      
      if device = flinker.device
        tracking.device_uuid = device.uuid
        tracking.os = device.os
        tracking.os_version = device.os_version
        tracking.version = device.version
        tracking.build = device.build
        tracking.phone = device.phone
      end
    end

    tracking
  end
end


