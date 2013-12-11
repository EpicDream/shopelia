namespace :shopelia do
  namespace :scrape do
  
    desc "Scrape new blogs posts if blog is to be scraped"
    task :blogs => :environment do
      Blog.scraped.find_each do |blog| 
        blog.fetch
      end
    end
    
    desc "set if we can post comments on blog posts"
    task :can_comment => :environment do
      Blog.find_each do |blog|
        blog.can_comment?(checkout:true)
      end
    end

  end
end
