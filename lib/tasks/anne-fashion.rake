namespace :anne_fashion do
  namespace :twitter do
    
    desc "publish message on timeline"
    task :publish => :environment do
      require 'anne_fashion/twitter'
      2.times { AnneFashion::Twitter.new.publish }
    end
    
  end
end