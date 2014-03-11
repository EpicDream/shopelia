class Comment < ActiveRecord::Base
  act_as_flink_activity :comment_timeline
  act_as_flink_activity :comment
  act_as_flink_activity :mention
  
  attr_accessible :body , :flinker_id, :look_id , :posted
  attr_accessor :post_to_blog
  
  belongs_to :look
  belongs_to :flinker, touch: true
  
  validates :flinker_id, :presence => true
  validates :look_id, :presence => true
  
  after_create :post_comment_on_blog_async, if: -> { can_be_posted_on_blog? && post_to_blog }
  
  scope :posted, -> { where(posted:true) }
  scope :last_ones, ->(n=10) { order('created_at desc').limit(n) }
  scope :timeline, ->(look_id) { where(look_id:look_id) }
  
  def to_html
    "#{self.body} <br/> sent via  <a href='http://flink.io'>Flink app</a>"
  end
  
  def can_be_posted_on_blog?
    look.post.blog.can_comment?
  end

  def post_on_blog
    poster = Poster::Comment.new(comment:self.to_html, author:flinker.username, email:sender, post_url:look.url)
    self.posted = poster.deliver
    self.save
  end
  
  def post
    Post.where(look_id:look_id).first
  end
  
  def blog
    post.blog
  end

  private
  
  def post_comment_on_blog_async
    CommentsWorker.perform_async(self.id)
  end
  
  def sender
    Shopelia::Application.config.flinker_google_account[:email]
  end

end
