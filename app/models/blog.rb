require 'scrapers/blogs/blog'
require 'poster/comment'

class Blog < ActiveRecord::Base
  attr_accessible :url, :name, :avatar_url, :country, :scraped, :flinker_id, :skipped, :can_comment
  
  belongs_to :flinker
  has_many :posts, dependent: :destroy, order: 'published_at desc'

  before_validation :normalize_url
  validates :url, uniqueness:true, presence:true, :on => :create
  after_create :assign_flinker, if: -> { self.flinker_id.nil? }
  after_update :update_flinker_avatar, if: -> { self.avatar_url_changed? }

  scope :without_posts, -> { where('not exists (select id from posts where posts.blog_id = blogs.id)') }
  scope :scraped, ->(scraped=true) { where(scraped:scraped) }
  scope :not_scraped, -> { scraped(false) }
  scope :skipped, ->(skipped=true) { where(skipped:skipped) }
  scope :not_skipped, -> { skipped(false) }
  scope :with_name_like, ->(pattern) { 
    where('url ~* :pattern or name ~* :pattern', pattern:pattern) unless pattern.blank?
  }
  
  def fetch
    self.update_attributes(scraped:true) unless self.scraped
    posts = Scrapers::Blogs::Blog.new(url).posts.map(&:modelize)
    posts.each do |post|
      post.blog_id = self.id
      post.save
    end
    self.reload.breakdown?
    self
  rescue => e
    report_incident(:fetch, e.message)
  end

  def skipped=skip
    self.scraped = false if skip
    write_attribute(:skipped, skip)
  end
  
  def scraped=scrap
    self.skipped = false if scrap
    write_attribute(:scraped, scrap)
    can_comment?(checkout:true) if scrap
    scrap
  end
  
  def country
    read_attribute(:country) || 'FR'
  end
  
  def can_comment? opt={}
    return read_attribute(:can_comment) unless opt[:checkout]
    return if posts.none?
    poster = Poster::Comment.new
    poster.post_url = posts.last.link
    self.can_comment = !!poster.publisher
    self.save
    can_comment?
  end

  def breakdown?
    breakdown = !self.posts.first || self.posts.first.published_at < Time.now - 1.month
    report_incident(:check_breakdown, "No post since 1 month...") if breakdown
    breakdown
  end
  
  private
  
  def report_incident method, description=nil
    Incident.create(
      :issue => "Blog##{method}",
      :severity => Incident::IMPORTANT,
      :description => "url : #{self.url} - #{description}")
  end
  
  def assign_flinker
    email = "#{SecureRandom.hex(4)}@flinker.io"
    password = SecureRandom.hex(4)
    country = Country.find_by_iso(self.country)
    flinker = Flinker.create(
      name:self.name, 
      url:self.url, 
      email:email, 
      password:password, 
      password_confirmation:password, 
      is_publisher:true, 
      country_id:country.id, 
      avatar_url:self.avatar_url)
    update_attribute :flinker_id, flinker.id
  end
  
  def update_flinker_avatar
    self.flinker.avatar_url = self.avatar_url
    self.flinker.save!
  end
  
  def normalize_url
    self.url.gsub!(/\/$/, '') if self.url
  end 
end
