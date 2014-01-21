class CommentsWorker
  include Sidekiq::Worker
  
  def perform comment_id
    Comment.find(comment_id).post_on_blog
  end
end
