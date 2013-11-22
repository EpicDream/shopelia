require 'scrapers/blogs/blog'

class Blog < ActiveRecord::Base
  attr_accessible :url
  has_many :posts
  
  validates :url, uniqueness:true, presence:true, :on => :create
  
  def fetch
    posts = Scrapers::Blogs::Blog.new(self.url).posts.map(&:modelize)
    self.posts << posts
  end
  
end
