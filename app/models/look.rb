class Look < ActiveRecord::Base
  attr_accessible :flinker_id, :name, :url, :published_at, :is_published, :description, :flink_published_at 
  
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
  before_update :touch_flink_published_at, if: -> { is_published_changed? }
  
  scope :published, -> { where(is_published:true) }
  scope :published_of_blog, ->(blog) { published.where(id:Post.where(blog_id:blog.id).select('look_id'))}
  scope :top_commented, ->(n=5) { 
    Look.joins(:comments).group('looks.id').order('count(*) desc').select('looks.id, count(*) as count').limit(n) 
  }
  scope :updated_after, ->(date) {
    where('flink_published_at < ? and updated_at > ?', date, date)
   }
  scope :of_flinker_followings, ->(flinker){#TODO:refactor using jointure
    if flinker
      flinkers_ids = flinker.followings.map(&:id)
      looks_ids = FlinkerLike.likes_for(flinker.friends).map(&:resource_id)
    
      (flinkers_ids.any? || looks_ids.any?) && published.where('flinker_id in (?) or id in (?)', flinkers_ids, looks_ids)
    end
  }
  scope :published_between, ->(since, before) {
    since ||= Time.at(0)
    before ||= Date.today
    published.where("published_at > ? and published_at < ?", since, before)
  }
  scope :flink_published_between, ->(since, before) {
    since ||= Time.at(0)
    before ||= Date.today
    published.where("flink_published_at > ? and flink_published_at < ?", since, before)
  }
  scope :with_comment_matching, ->(pattern) {
    joins(:comments).where('comments.body ~* ?', pattern)
  }
  scope :liked_by, ->(flinker) {
    joins('join flinker_likes on flinker_likes.resource_id = looks.id').where('flinker_likes.flinker_id = ?', flinker.id)
  }
  
  def self.random collection=Look
    collection.offset(rand(collection.count)).first
  end
  
  def self.publications_counts_per_day from=(Date.today - 7.days)
    sql = "select flink_published_at::DATE, count(*) from looks where is_published='t' and 
    flink_published_at >= '#{from.to_s(:db)}' group by flink_published_at::DATE order by flink_published_at desc"
    connection.execute(sql)
  end

  def mark_post_as_processed
    self.post.update_attributes(processed_at:Time.now)
  end

  def liked_by? flinker
    !FlinkerLike.where("flinker_id=? and resource_type=? and resource_id=?", flinker.id, FlinkerLike::LOOK, self.id).empty?
  end

  private
  
  def touch_flink_published_at 
    self.flink_published_at = Time.now
  end

  def generate_uuid
    self.uuid = SecureRandom.hex(4) if self.uuid.blank?
  end

  def update_flinker_looks_count
    self.flinker.update_attribute :looks_count, self.flinker.looks.where(is_published:true).count
  end
end