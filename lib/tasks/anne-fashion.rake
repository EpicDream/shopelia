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
    
    desc "follow from fashion tweets"
    task :follow_from_tweets => :environment do
      AnneFashion::Twitter.new.follow_from_tweets("#lookbook")
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
    
    desc "follow some friends of some followers"
    task :follow_friends_of_followers => :environment do
      AnneFashion::Instagram.new.follow_friends_of_followers
    end
    
    desc "schedule followings/followers ratio"
    task :schedule => :environment do
      AnneFashion::Instagram.new.schedule_follow_ratio
    end
    
  end
  
end