namespace :shopelia do
  namespace :scrape do
  
    desc "Scrape new blogs posts"
    task :blogs => :environment do
      Blog.find_each do |blog| 
        blog.fetch
      end
    end
    
  end
end
