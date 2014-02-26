Sidekiq.configure_server do |config|
  Sidekiq::Scheduled.send(:remove_const, "POLL_INTERVAL")
  Sidekiq::Scheduled.const_set("POLL_INTERVAL", 1)
  
  config.redis = { url: 'redis://localhost:6379/0', namespace: "flink_#{Rails.env}" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://localhost:6379/0', namespace: "flink_#{Rails.env}" }
end     