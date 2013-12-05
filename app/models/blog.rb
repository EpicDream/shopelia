require 'scrapers/blogs/blog'

class Blog < ActiveRecord::Base
  attr_accessible :url, :name, :avatar_url, :country, :scraped, :flinker_id, :skipped
  
  belongs_to :flinker
  has_many :posts, dependent: :destroy
  
  before_validation :normalize_url
  validates :url, uniqueness:true, presence:true, :on => :create
  after_create :assign_flinker, if: -> { self.flinker_id.nil? }
  
  scope :without_posts, -> { where('not exists (select id from posts where posts.blog_id = blogs.id)') }
  scope :scraped, ->(scraped=true) { where(scraped:scraped) }
  scope :not_scraped, -> { scraped(false) }
  scope :skipped, -> { where(skipped:true) }
  
  def fetch
    self.update_attributes(scraped:true) unless self.scraped
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
    email = "#{SecureRandom.hex(4)}@flinker.io"
    password = SecureRandom.hex(4)
    flinker = Flinker.create(name:self.name, url:self.url, email:email, password:password, password_confirmation:password, is_publisher:true)
    update_attribute :flinker_id, flinker.id
  end
  
  def normalize_url
    self.url.gsub!(/\/$/, '')
  end 
end