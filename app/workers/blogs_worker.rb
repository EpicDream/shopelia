class BlogsWorker
  include Sidekiq::Worker

  def perform blog_id
    Blog.find(blog_id).fetch
  end
end
