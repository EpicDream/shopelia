class Look < ActiveRecord::Base
  attr_accessible :flinker_id, :name, :url, :published_at, :is_published, :description, :flink_published_at, :bitly_url
  attr_accessible :hashtags_attributes, :season
  
  belongs_to :flinker
  has_one :post
  has_many :comments
  has_many :look_images, :foreign_key => "resource_id", :dependent => :destroy
  has_many :look_products, :dependent => :destroy
  has_many :products, :through => :look_products
  has_many :flinker_likes, foreign_key:'resource_id'
  has_and_belongs_to_many :hashtags, uniq:true, after_remove: :may_destroy_hashtag
  
  validates :uuid, :presence => true, :uniqueness => true, :on => :create
  validates :flinker, :presence => true
  validates :name, :presence => true
  validates :url, :presence => true, :format => {:with => /\Ahttp/}
  validates :published_at, :presence => true

  before_validation :generate_uuid
  before_validation :find_or_create_hashtag
  after_save :update_flinker_looks_count
  after_update :may_reindex_flinker, if: -> { is_published_changed? }
  before_update :touch_flink_published_at, if: -> { is_published_changed? }
  after_update :revive_flinkers, if: -> { is_published_changed? && is_published? }
  
  accepts_nested_attributes_for :hashtags, allow_destroy: true, reject_if: ->(attributes) { attributes['name'].blank? }
  
  scope :published, -> { where(is_published:true) }
  scope :published_of_blog, ->(blog) { published.where(id:Post.where(blog_id:blog.id).select('look_id'))}
  scope :top_commented, ->(n=5) { 
    Look.flink_published_between(Time.now - 5.days, Time.now)
    .joins(:comments)
    .group('looks.id')
    .order('count(*) desc')
    .select('looks.id, count(*) as count').limit(n) 
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
    case 
    when since then published.where("flink_published_at >= ?", since)
    when before then published.where("flink_published_at <= ?", before)
    else published
    end
  }
  scope :with_comment_matching, ->(pattern) {
    joins(:comments).where('comments.body ~* ?', pattern)
  }
  scope :liked_by, ->(flinker) {
    joins('join flinker_likes on flinker_likes.resource_id = looks.id').where('flinker_likes.flinker_id = ?', flinker.id)
  }
  scope :with_hashtags, ->(hashtags){
    hashtags = Hashtag.where('name ~* ?', hashtags.join("|")).select(:id).uniq
    Look.joins(:hashtags).where('hashtags_looks.hashtag_id in(?)', hashtags.map(&:id)).uniq
  }
  scope :with_hashtags_strict, ->(keywords){
    regexp = keywords.map { |keyword| "^#{keyword}$" }.join("|")
    hashtags = Hashtag.where('name ~* ?', regexp).select(:id).uniq
    Look.joins(:hashtags).where('hashtags_looks.hashtag_id in(?)', hashtags.map(&:id)).uniq
  }
  scope :with_likes_count, -> {
    joins("left outer join (select resource_id, count(*) from flinker_likes where resource_type='look' group by resource_id) likes on likes.resource_id = looks.id")
    .select('coalesce(count, 0) as flikes_count')
  }
  scope :from_country, -> (country_id) {
    joins(:flinker).where('flinkers.country_id = ?', country_id) unless country_id.blank?
  }
  
  alias_attribute :published, :is_published
  
  def self.search keywords, country_id=nil
    return where(id:nil) if keywords.empty?
    published.with_hashtags_strict(keywords)
    .from_country(country_id)
    .with_likes_count
    .includes(:look_images)
    .select('looks.*')
    .order('flikes_count desc, flink_published_at desc')
  end
  
  def self.search_for_api keywords
    return where(id:nil) if keywords.empty?
    keywords = keywords.compact.map{ |keyword| keyword.delete('#') }
    published.with_hashtags(keywords)
    .order('flink_published_at desc')
  end
  
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
  
  def bitly_url
    @bitly_url = read_attribute(:bitly_url)
    unless @bitly_url
      @bitly_url = Bitly.client.shorten("http://www.flink.io/looks/#{self.uuid}").short_url
      self.update_attributes(bitly_url: @bitly_url)
    end
    @bitly_url
  end
  
  def image_for_cover
    look_images.order('display_order asc').limit(1).first
  end
  
  def hashtags_as_strings
    hashtags.map(&:name).map { |hashtag| "##{hashtag}" }
  end
  
  def publish
    update_attributes(is_published: true)
  end

  private
  
  def may_destroy_hashtag record
    return if record.new_record? #bug rails on callback after_remove, pass here even when add and not remove
    hashtag = Hashtag.find_by_name(record.name)
    hashtag.destroy if hashtag && hashtag.reload.looks.count.zero?
  end
  
  def find_or_create_hashtag
    self.hashtags = self.hashtags.map { |hashtag|  
      if hashtag.new_record?
        Hashtag.find_or_create_by_name(hashtag.name)
      else
        hashtag
      end
    }.uniq
  end
  
  def touch_flink_published_at 
    self.flink_published_at = Time.now
  end

  def generate_uuid
    self.uuid = SecureRandom.hex(4) if self.uuid.blank?
  end

  def update_flinker_looks_count
    self.flinker.update_attribute :looks_count, self.flinker.looks.where(is_published:true).count
  end
  
  def may_reindex_flinker
    count = self.flinker.looks.published.count
    if count.zero?
      self.flinker.remove_from_index!
    elsif count == 1
      self.flinker.index!
    end
  end
  
  def revive_flinkers
    #WAIT NEW RELEASE
    #flinkers = Flinker.top_likers_of_publisher_of_look(self)
    #Revival.revive!(flinkers, self)
  end
  
end