namespace :anne_fashion do
  namespace :twitter do
    
    desc "publish message on timeline"
    task :publish => :environment do
      require 'anne_fashion/twitter'
      AnneFashion::Twitter.new.publish(3)
    end
    
  end
end