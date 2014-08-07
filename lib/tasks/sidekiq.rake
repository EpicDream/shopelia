namespace :flink do
  namespace :sidekiq do
    
    desc "Clean sidekiq when blocked"
    task :clean => :environment do
      require 'sidekiq/api'
      Sidekiq::Queue.new('blogs_scraper').each(&:delete)
      Sidekiq::RetrySet.new.clear
      Sidekiq.redis {|c| c.del('stat:failed') }
    end

  end
end
