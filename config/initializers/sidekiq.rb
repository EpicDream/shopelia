Sidekiq.configure_server do |config|
  Sidekiq::Scheduled.send(:remove_const, "POLL_INTERVAL")
  Sidekiq::Scheduled.const_set("POLL_INTERVAL", 1)
end