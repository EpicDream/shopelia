require 'timeout'

class BlogsWorker
  include Sidekiq::Worker
  TIMEOUT = 15.minutes
  sidekiq_options :queue => :blogs_scraper, retry:false
  
  def perform blog_id
    Timeout::timeout(TIMEOUT) {
      Blog.find(blog_id).fetch
    }
  end
end
