namespace :shopelia do
  namespace :stats do
    
    desc "Push stats to Leftronic dashboard"
    task :leftronic => :environment do
      l = Leftronic.new
      l.notify_button_stats
    end

  end
end
