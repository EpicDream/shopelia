namespace :scrape do
  
  desc "Scrape new blogs posts"
  task :blogs => :environment do
    Blog.all.find_each { |blog| blog.fetch }
  end
  
end
