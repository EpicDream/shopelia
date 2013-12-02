require 'scrapers/blogs/blog'

class Blog < ActiveRecord::Base
  attr_accessible :url, :name
  has_many :posts, dependent: :destroy
  validates :url, uniqueness:true, presence:true, :on => :create

  scope :without_posts, -> { where('not exists (select id from posts where posts.blog_id = blogs.id)') }
  
  def fetch
    self.posts << Scrapers::Blogs::Blog.new(url).posts.map(&:modelize)
    self.reload
  end
  
  def self.batch_create_from_csv content
    blogs = []
    CSV.parse(content) { |row| blogs << Blog.create({name:row[1], url:row[0]}) }
    blogs
  end
  
end
