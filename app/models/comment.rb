class Comment < ActiveRecord::Base
  POST_ON_BLOG = false
  act_as_flink_activity :comment_timeline
  act_as_flink_activity :comment
  act_as_flink_activity :mention
  
  attr_accessible :body , :flinker_id, :look_id , :posted, :admin_read
  attr_accessor :post_to_blog
  
  belongs_to :look
  belongs_to :flinker
  
  validates :flinker_id, :presence => true
  validates :look_id, :presence => true
  validate :flinker_can_comment?
  
  after_create :post_comment_on_blog_async, if: -> { POST_ON_BLOG && can_be_posted_on_blog? && post_to_blog }
  after_create :create_hashtags_and_assign_to_look
  
  scope :posted, -> { where(posted:true) }
  scope :last_ones, -> { 
    Comment.order('created_at desc, look_id desc')
  }
  scope :timeline, ->(look_id) { where(look_id:look_id) }
  scope :admin_unread, -> { where(admin_read:false) }
  scope :for_publisher, ->(publisher) {
    joins(:look).where('looks.flinker_id = ?', publisher.id)
  }
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
  
  def create_hashtags_and_assign_to_look
    hashtags = self.body.scan(/#([[[:alnum:]]]+)/).flatten.map { |name| 
      Hashtag.find_or_create_by_name(name) 
    }
    self.look.hashtags << hashtags
  end

  private
  
  def flinker_can_comment?
    can_comment = Flinker.find(self.flinker_id).can_comment?
    self.errors.add(:cannot_comment, "Can't comment") unless can_comment
    can_comment
  end
  
  def post_comment_on_blog_async
    CommentsWorker.perform_async(self.id)
  end
  
  def sender
    Shopelia::Application.config.flinker_google_account[:email]
  end

end
