namespace :anne_fashion do
  namespace :twitter do
    require 'anne_fashion/twitter'
    
    desc "publish message on timeline"
    task :publish => :environment do
      AnneFashion::Twitter.new.publish(3)
    end
    
    desc "follow friends of friends"
    task :follow_friends_of_friends => :environment do
      AnneFashion::Twitter.new.follow_friends_of_friends(10)
    end
    
    desc "schedule followings/followers ratio"
    task :schedule => :environment do
      AnneFashion::Twitter.new.schedule_follow_ratio
    end
    
  end
  
  namespace :instagram do
    require 'anne_fashion/instagram'
    
    desc "follow and like"
    task :follow_and_like_by_tag => :environment do
      AnneFashion::Instagram.new.follow_and_like_by_tag('fashion')
    end
    
    desc "schedule followings/followers ratio"
    task :schedule => :environment do
      AnneFashion::Instagram.new.schedule_follow_ratio
    end
    
  end
  
end