require 'debugger'

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

  namespace :vine do
    desc "Follow and like vines from people commenting on the popular page"
    task :popular_page => :environment do
      require 'anne_fashion/vine'
      vine = AnneFashion::Vine.new("flinkHQ")
      vine.popular_page
    end

    desc "Follow and like vines from people in fashion tag"
    task :fashion_tag => :environment do
      require 'anne_fashion/vine'
      vine = AnneFashion::Vine.new("flinkHQ")
      vine.follow_from_tag("fashion")
    end

    desc "vampirize a user"
    task :vampire => :environment do
      require 'anne_fashion/vine'
      vine = AnneFashion::Vine.new("flinkHQ")
      vine.vampirize_user("1017415403934298112")
    end

  end
end