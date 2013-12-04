require 'scrapers/blogs/blog'

class Blog < ActiveRecord::Base
  attr_accessible :url, :name, :avatar_url, :country, :scraped, :flinker_id
  
  belongs_to :flinker
  has_many :posts, dependent: :destroy
  
  validates :url, uniqueness:true, presence:true, :on => :create
  after_create :assign_flinker, if: -> { self.flinker_id.nil? }
  
  scope :without_posts, -> { where('not exists (select id from posts where posts.blog_id = blogs.id)') }
  
  def fetch
    posts = Scrapers::Blogs::Blog.new(url).posts.map(&:modelize)
    posts.each do |post|
      post.blog_id = self.id
      post.save
    end
    self.reload
  end
  
  def self.batch_create_from_csv content
    blogs = []
    CSV.parse(content) { |row| blogs << Blog.create({name:row[1], url:row[0]}) }
    blogs
  end
  
  private
  
  def assign_flinker
    flinker = Flinker.create(name:self.name, url:self.url)
    update_attribute :flinker_id, flinker.id
  end
  
end
