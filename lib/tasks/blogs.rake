namespace :shopelia do
  namespace :scrape do
  
    desc "Scrape new blogs posts if blog is to be scraped"
    task :blogs => :environment do
      Blog.scraped.find_each do |blog| 
        BlogsWorker.perform_async(blog.id)
      end
    end
    
    desc "set if we can post comments on blog posts"
    task :can_comment => :environment do
      Blog.find_each do |blog|
        blog.can_comment?(checkout:true) unless blog.can_comment?
      end
    end
    
    desc "integrate blogs from lookbook"
    task :lookbook => :environment do
      require 'crawlers/lookbook/blogs'
      
      countries = ["united-kingdom", "italy", "united-states", "germany"]
      countries.each do |country|
        Crawlers::Lookbook::Blogs.new(country).fetch
      end
    end
    

  end
end
