namespace :anne_fashion do
  namespace :twitter do
    
    desc "publish message on timeline"
    task :publish => :environment do
      require 'anne_fashion/twitter'
      AnneFashion::Twitter.new.publish(3)
    end
    
    desc "schedule followings/followers ratio"
    task :schedule => :environment do
      require 'anne_fashion/twitter'
      AnneFashion::Twitter.new.schedule_follow_ratio
    end
    
  end
end