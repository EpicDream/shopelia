namespace :anne_fashion do
  namespace :twitter do
    
    desc "publish message on timeline"
    task :publish => :environment do
      require 'anne_fashion/twitter'
      AnneFashion::Twitter.new.publish(3)
    end
    
    desc "follow friends of friends"
    task :follow_friends_of_friends => :environment do
      require 'anne_fashion/twitter'
      AnneFashion::Twitter.new.follow_friends_of_friends(10)
    end
    
    desc "schedule followings/followers ratio"
    task :schedule => :environment do
      require 'anne_fashion/twitter'
      AnneFashion::Twitter.new.schedule_follow_ratio
    end
    
  end
end