require 'scrapers/blogs/blog'

class Blog < ActiveRecord::Base
  attr_accessible :url
  has_many :posts
  
  validates :url, uniqueness:true, presence:true, :on => :create
  
  def fetch
    self.posts << Scrapers::Blogs::Blog.new(url).posts.map(&:modelize)
    self.reload
  end
  
end
