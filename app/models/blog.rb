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
  scope :with_name_like, ->(pattern) { 
    where('url like :pattern or name like :pattern', pattern:"%#{pattern}%") unless pattern.blank?
  }
  
  def fetch
    self.update_attributes(scraped:true) unless self.scraped
    posts = Scrapers::Blogs::Blog.new(url).posts.map(&:modelize)
    posts.each do |post|
      post.blog_id = self.id
      post.save
    end
    self.reload
  end

  def skipped=skip
    self.scraped = false if skip
    write_attribute(:skipped, skip)
  end
  
  def scraped=scrap
    self.skipped = false if scrap
    write_attribute(:scraped, scrap)
  end
  
  def country
    read_attribute(:country) || 'FR'
  end
  
  private
  
  def assign_flinker
    flinker = Flinker.create(name:self.name, url:self.url)
    update_attribute :flinker_id, flinker.id
  end
  
  def normalize_url
    self.url.gsub!(/\/$/, '')
  end
  
end
