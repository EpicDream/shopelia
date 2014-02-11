namespace :shopelia do
  namespace :stats do
    
    desc "Push stats to Leftronic dashboard"
    task :leftronic_stats => :environment do
      l = Leftronic.new
      l.notify_button_stats
      l.notify_viking_stats
    end
    
    desc "Send daily global stats email"
    task :daily => :environment do
      stats = DailyStats.new
      stats.send_email
    end

  end
end
