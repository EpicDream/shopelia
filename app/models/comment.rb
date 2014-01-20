class Comment < ActiveRecord::Base
  belongs_to :look
  belongs_to :flinker
  attr_accessible :body , :flinker_id, :look_id
  after_create :post_comment_on_blog, if: -> { self.can_be_posted_on_blog? }

  GOOGLE_ACCOUNT = Shopelia::Application.config.flinker_google_account

  def formatted_body
    "#{self.flinker.username} <br/> #{self.body} <br/> send via  <a href='http://flink.io'>flink</a>}"
  end
  
  def can_be_posted_on_blog?
    self.look.post.blog.can_comment?
  end

  private
  
  def post_comment_on_blog
    @poster = Poster::Comment.new(comment:formatted_body, author:flinker.username, email:GOOGLE_ACCOUNT[:email], post_url:look.url)
    @poster.deliver
  end

end
