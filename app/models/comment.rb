class Comment < ActiveRecord::Base
  belongs_to :look
  belongs_to :flinker
  attr_accessible :body , :flinker_id, :look_id
  after_create :post_comment_to_blog

  GOOGLE_ACCOUNT = Shopelia::Application.config.flinker_google_account

  def format_comment
    "#{self.flinker.username} <br/> #{self.body} <br/> send via  <a href='http://flink.io'>flink</a>}"
  end

  def self.create_comment_for_look(comment, uuid)
    look = Look.find_by_uuid(uuid)
    look.comments.create(comment)
  end

  def post_comment_to_blog
    if self.look.post.blog.can_comment?
      @poster = Poster::Comment.new(comment:self.format_comment, author:comment.flinker.username, email:GOOGLE_ACCOUNT[:email], post_url:self.look.url)
      @poster.deliver
    end
  end

end
