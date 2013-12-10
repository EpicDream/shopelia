namespace :shopelia do
  namespace :scrape do
  
    desc "Scrape new blogs posts if blog is to be scraped"
    task :blogs => :environment do
      Blog.scraped.find_each do |blog| 
        blog.fetch
      end
    end

    desc "Convert rss link to html link"
    task :clean_posts_links => :environment do
      require 'scrapers/blogs/blog'
      parser = Scrapers::Blogs::RSSFeed.new("")
      
      Post.where('link ~* ?', 'feeds.*?commen').each do |post|
        html_link = parser.html_link(post.link)
        post.update_attributes(link:html_link) 
      end
    end
  end
end
