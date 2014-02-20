class Look < ActiveRecord::Base
  attr_accessible :flinker_id, :name, :url, :published_at, :is_published, :description, :is_published_updated_at
  
  belongs_to :flinker
  has_one :post
  has_many :comments
  has_many :look_images, :foreign_key => "resource_id", :dependent => :destroy
  has_many :look_products, :dependent => :destroy
  has_many :products, :through => :look_products

  validates :uuid, :presence => true, :uniqueness => true, :on => :create
  validates :flinker, :presence => true
  validates :name, :presence => true
  validates :url, :presence => true, :format => {:with => /\Ahttp/}
  validates :published_at, :presence => true

  before_validation :generate_uuid
  after_save :update_flinker_looks_count
  before_update :touch_is_published_updated_at, if: -> { is_published_changed? }
  
  scope :published, -> { where(is_published:true) }
  scope :published_of_blog, ->(blog) { published.where(id:Post.where(blog_id:blog.id).select('look_id'))}
  scope :top_commented, ->(n=5) { 
    Look.joins(:comments).group('looks.id').order('count(*) desc').select('looks.id, count(*) as count').limit(n) 
  }
  scope :published_updated_after, ->(date) { where('is_published_updated_at < ? and updated_at >= ?', date, date)}
  
  def self.random collection=Look
    collection.offset(rand(collection.count)).first
  end
  
  def self.publications_counts_per_day from=(Date.today - 7.days)
    sql = "select is_published_updated_at::DATE, count(*) from looks where is_published='t' and 
    is_published_updated_at >= '#{from.to_s(:db)}' group by is_published_updated_at::DATE order by is_published_updated_at desc"
    connection.execute(sql)
  end

  def mark_post_as_processed
    self.post.update_attributes(processed_at:Time.now)
  end

  def liked_by? flinker
    !FlinkerLike.where("flinker_id=? and resource_type=? and resource_id=?", flinker.id, FlinkerLike::LOOK, self.id).empty?
  end

  private
  
  def touch_is_published_updated_at
    self.is_published_updated_at = Time.now
  end

  def generate_uuid
    self.uuid = SecureRandom.hex(4) if self.uuid.blank?
  end

  def update_flinker_looks_count
    self.flinker.update_attribute :looks_count, self.flinker.looks.where(is_published:true).count
  end
end