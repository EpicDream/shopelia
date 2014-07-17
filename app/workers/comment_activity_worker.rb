class CommentActivityWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :activities, retry:false
  
  def perform comment_id
    comment = Comment.find(comment_id)
    comment.flinker.followers.each do |friend|
      next if CommentTimelineActivity.for_comment_and_target(comment, friend).first
      CommentActivity.create(flinker_id:comment.flinker_id, target_id:friend.id, resource_id:comment.id)
    end
  end
end
