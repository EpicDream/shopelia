namespace :leftronic_flink_weekly_tasks do
  namespace :stats do
    require 'leftronic_stats/stats'
    desc "publish % of weekly active users on leftronic"
    task :mau => :environment do
      percentage_wau = LeftronicStats::Stats.new.get_active_users_from(1.week.ago)
      Leftronic.new.notify_wau_count(percentage_wau)
    end
  end
end

