class Comment < ActiveRecord::Base
  attr_accessible :body , :flinker_id, :look_id , :posted
  attr_accessor :post_to_blog
  
  belongs_to :look
  belongs_to :flinker
  
  after_create :post_comment_on_blog, if: -> { can_be_posted_on_blog? && post_to_blog }
  
  def to_html
    "#{self.flinker.username} <br/> #{self.body} <br/> send via  <a href='http://flink.io'>flink</a>"
  end
  
  def can_be_posted_on_blog?
    look.post.blog.can_comment?
  end

  private
  
  def post_comment_on_blog
    poster = Poster::Comment.new(comment:self.to_html, author:flinker.username, email:sender, post_url:look.url)
    self.posted = poster.deliver
    self.save
  end
  
  def sender
    Shopelia::Application.config.flinker_google_account[:email]
  end

end
