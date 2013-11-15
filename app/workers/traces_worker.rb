class TracesWorker
  include Sidekiq::Worker

  def perform hash
    Trace.create!(
      :user_id => hash["user_id"],
      :device_id => hash["device_id"],
      :resource => hash["resource"],
      :action => hash["action"],
      :extra_id => hash["extra_id"].blank? ? nil : hash["extra_id"].to_i,
      :extra_text => hash["extra_text"],
      :ip_address => hash["ip_address"])
  end
end
