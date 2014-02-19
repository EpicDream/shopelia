require 'timeout'

class BlogsWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :blogs_scraper, retry:false
  
  def perform blog_id
    Blog.find(blog_id).fetch
  end
end
