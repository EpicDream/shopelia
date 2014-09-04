require 'scrapers/blogs/blog'
require 'poster/comment'

class Blog < ActiveRecord::Base
  attr_accessible :url, :name, :avatar_url, :country, :scraped, :flinker_id
  attr_accessible :username, :skipped, :can_comment
  attr_accessor :username
  
  belongs_to :flinker
  has_many :posts, dependent: :destroy, order: 'published_at desc'

  before_validation :normalize_url
  before_validation :assign_flinker, if: -> { self.flinker_id.nil? }

  validates :url, uniqueness:true, presence:true, :on => :create
  validates :name, presence:true
  validates :flinker_id, presence:true
  
  after_update :update_flinker_avatar, if: -> { self.avatar_url_changed? }

  scope :without_posts, -> { where('not exists (select id from posts where posts.blog_id = blogs.id)') }
  scope :without_posts_since, ->(date) { 
    where("not exists (select id from posts where posts.blog_id = blogs.id and posts.published_at >= '#{date}')") 
  }
  scope :without_posts_since_one_month, -> { without_posts_since(Date.today - 1.month)}
  scope :scraped, ->(scraped=true) { where(scraped:scraped) }
  scope :not_scraped, -> { scraped(false) }
  scope :skipped, ->(skipped=true) { where(skipped:skipped) }
  scope :not_skipped, -> { skipped(false) }
  scope :with_name_like, ->(pattern) { 
    where('url ~* :pattern or name ~* :pattern', pattern:pattern) unless pattern.blank?
  }
  scope :without_look_published, ->(interval=30.days) {
    joins("join looks on looks.flinker_id=blogs.flinker_id")
    .where("looks.is_published = 't'")
    .where("flink_published_at is not null")
    .where("not exists(
      select id from looks
      where looks.flinker_id=blogs.flinker_id
      and looks.flink_published_at::DATE >= '#{Time.now - interval}'
      )")
    .uniq
  }
  
  scope :recent, -> {
    where('created_at >= ?', Date.today - 1.month)
  }
  scope :of_country, -> (code) {
    where(country: code) unless code.blank?
  }
  
  def fetch
    self.update_attributes(scraped:true) unless self.scraped
    posts = Scrapers::Blogs::Blog.new(url).posts.map(&:modelize)
    posts.each do |post|
      post.blog_id = self.id
      post.save
    end
    self
  rescue => e
    Incident.report(:Blog, :fetch, "#{self.url} - #{e.message}")
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
    !self.posts.first || self.posts.first.published_at < Time.now - 1.month
  end
  
  def self.names
    connection.execute("select name from blogs where name <> '' and name is not null").map { |r| r["name"]  }
  end
  
  def self.last_published_look_of blog
    Look.published.where(flinker_id: blog.flinker_id).order('flink_published_at asc').last
  end
  
  private
  
  def assign_flinker
    email = "#{SecureRandom.hex(4)}@flinker.io"
    password = SecureRandom.hex(4)
    country = Country.find_by_iso(self.country || 'FR')
    flinker = Flinker.create(
      name:self.name,
      username:self.username || self.name.gsub(/[^\w\d]/, SecureRandom.hex(1)),
      url:self.url, 
      email:email,
      password:password,
      password_confirmation:password, 
      is_publisher:true, 
      country_id:country.id, 
      avatar_url:self.avatar_url)
    unless flinker.valid? 
      self.errors.add(:flinker, "Can't create flinker") 
    else 
      self.flinker = flinker
    end
  end
  
  def update_flinker_avatar
    self.flinker.avatar_url = self.avatar_url
    self.flinker.save!
  end
  
  def normalize_url
    self.url.gsub!(/\/$/, '') if self.url
  end 
end
