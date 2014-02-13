namespace :leftronic_flink_daily_tasks do
  namespace :stats do
    require 'leftronic_stats/stats'
    desc "publish % of daily active users on leftronic"
    task :dau => :environment do
      percentage_dau = LeftronicStats::Stats.new.get_active_users_from(1.day.ago)
      Leftronic.new.notify_dau_count(percentage_dau)
    end
  end
end

