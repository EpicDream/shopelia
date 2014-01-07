class BlogsWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :blogs_scraper
  
  def perform blog_id
    Blog.find(blog_id).fetch
  end
end
