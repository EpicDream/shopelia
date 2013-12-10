namespace :shopelia do
  namespace :scrape do
  
    desc "Scrape new blogs posts if blog is to be scraped"
    task :blogs => :environment do
      Blog.scraped.find_each do |blog| 
        blog.fetch
      end
    end

  end
end
