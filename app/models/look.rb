class Look < ActiveRecord::Base
  extend FriendlyId
  MIN_LIKES_FOR_POPULAR = 150
  MIN_BUILD_FOR_STAFF_PICKS = 31
  
  friendly_id :publisher_and_look_name, use: :slugged
  
  attr_accessible :flinker_id, :name, :url, :published_at, :is_published, :description, :flink_published_at, :bitly_url
  attr_accessible :hashtags_attributes, :season, :staff_pick, :quality_rejected
  
  belongs_to :flinker
  has_one :post
  has_many :comments
  has_many :look_images, :foreign_key => "resource_id", :dependent => :destroy
  has_many :look_covers, :foreign_key => "resource_id", class_name:"LookImage", order: 'display_order asc', limit:1
  has_many :look_products, :dependent => :destroy
  has_many :products, :through => :look_products
  has_many :flinker_likes, foreign_key:'resource_id', :dependent => :destroy
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
  scope :of_flinker_followings, ->(flinker){#TODO:refactor using UNION
    if flinker
      flinkers_ids = flinker.followings.map(&:id)
      looks_ids = FlinkerLike.likes_for(flinker.friends).map(&:resource_id)
      looks_ids += Look.liked_by(flinker).map(&:id)
      looks_ids.uniq!
      
      if flinker.device && flinker.device.build < MIN_BUILD_FOR_STAFF_PICKS
        (flinkers_ids.any? || looks_ids.any?) && 
        published.where('flinker_id in (?) or id in (?)', flinkers_ids, looks_ids)
      else
        published.where('flinker_id in (?) or id in (?) or staff_pick = ?', flinkers_ids, looks_ids, true)
      end
    end
  }
  
  #DEPRECATED- build 22
  scope :published_between, ->(since, before) {
    since ||= Time.at(0)
    before ||= Date.today
    published.where("published_at > ? and published_at < ?", since, before)
  }
  
  #DEPRECATED- build 26
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
  scope :likes_of_flinker, ->(flinker){
    joins(:flinker_likes)
    .where('flinker_likes.flinker_id = ?', flinker.id) 
    .select('looks.*, EXTRACT(EPOCH FROM flinker_likes.updated_at) as like_updated_at')
  }
  scope :likes_with_status, ->(on) {
    joins(:flinker_likes).where('flinker_likes.on = ?', on)
  }
  scope :liked_by, ->(flinker) {
    likes_of_flinker(flinker).likes_with_status(true)
  }
  scope :unliked_by, ->(flinker) {
    likes_of_flinker(flinker).likes_with_status(false)
  }
  scope :likes_between, ->(from, to){
    from ||= Rails.configuration.min_date
    to ||= Time.now
    joins(:flinker_likes).where('flinker_likes.updated_at >= ? and flinker_likes.updated_at <= ?', from, to)
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
  scope :popular, ->(published_before=nil, published_after=nil) {
    recent(published_before, published_after)
    .joins("join (select resource_id, count(*) from flinker_likes 
            group by resource_id having count(*) >= #{MIN_LIKES_FOR_POPULAR}) likes
            on looks.id = likes.resource_id")
  }
  scope :recent, ->(published_before=nil, published_after=nil) {
    published_before ||= Time.now
    published_after ||= Rails.configuration.min_date

    published.where("flink_published_at <= '#{published_before}'")
    .where("flink_published_at >= '#{published_after}'")
  }
  scope :best, ->(published_before, published_after) {
    recent(published_before, published_after)
    .where(staff_pick:true)
  }
  scope :staff_picked, -> { where(staff_pick:true) }
  scope :flink_loves, -> { staff_picked }
  scope :staff_picked_countries, -> {
    staff_picked
    .joins(:flinker)
    .joins('join countries on flinkers.country_id = countries.id')
    .group('countries.name')
    .select('countries.name, count(*)')
  }
  scope :with_uuid, ->(uuid) {
    where(uuid: uuid.scan(/^[^\-]+/).flatten.first)
  }
  scope :random, ->(max=3, publisher=nil, except=nil) {
    looks = published.order('random()').limit(max)
    looks = looks.where('id != ?', except.id) if except
    looks = looks.where(flinker_id: publisher.id) if publisher
    looks
  }

  alias_attribute :published, :is_published
  
  def self.search keywords, country_id=nil
    return where(id:nil) if keywords.empty?
    published.with_hashtags_strict(keywords)
    .from_country(country_id)
    .with_likes_count
    .includes(:look_images)
    .select('looks.*')
    .order('flink_published_at desc, flikes_count desc')
  end
  
  def self.search_for_api keywords
    return where(id:nil) if keywords.empty?
    keywords = keywords.compact.map{ |keyword| keyword.delete('#') }
    published.with_hashtags(keywords)
    .order('flink_published_at desc')
  end
  
  def self.publications_counts_per_day from=(Date.today - 7.days)
    sql = "select flink_published_at::DATE, count(*) from looks where is_published='t' and 
    flink_published_at >= '#{from.to_s(:db)}' group by flink_published_at::DATE order by flink_published_at desc"
    connection.execute(sql)
  end
  
  def self.covers
    Look.published
    .order('flink_published_at desc')
    .includes(:look_covers)
    .includes(:flinker)
  end
  
  def publisher_and_look_name
    ["#{flinker.name}", "#{name}"]
  end
  
  def should_generate_new_friendly_id?
    new_record? || slug.blank?
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
      @bitly_url = Bitly.client.shorten(self.sharable_url).short_url
      self.update_attributes(bitly_url: @bitly_url)
    end
    @bitly_url
  end
  
  def image_for_cover
    look_images.order('display_order asc').limit(1).first
  end

  def cover_url
    Rails.configuration.image_host + look_covers.first.picture.url(:small)
  end

  def large_cover_url
    Rails.configuration.image_host + look_covers.first.picture.url(:large)
  end
  
  def hashtags_as_strings
    hashtags.map(&:name).map { |hashtag| "##{hashtag}" }
  end
  
  def publish
    update_attributes(is_published: true)
  end
  
  def highlighted_hashtags
    HighlightedLook.hashtags_of_look(self)
  end

  def trackable_url
    uri = Addressable::URI.parse(self.url)
    uri.query_values ||= {}
    uri.query_values = uri.query_values.merge({utm_source:'flink-web', utm_medium:'website'})
    uri.to_s
  end

  def deeplink_url
    "http://deeplink.me/#{Rails.configuration.deeplink_host}/looks/#{self.uuid}"
  end

  def app_deeplink_url
    "flink://looks/#{self.uuid}"
  end

  def sharable_title
    "#{self.name} by #{self.flinker.name} #{products_as_hashtags} @flinkhq #ootd #fashion #love #fashionblogger #flinkhq"
  end

  def sharable_url
    "#{Rails.configuration.host}/looks/#{self.friendly_id}"
  end

  def products_as_hashtags
    look_products.map { |product| "##{ product.brand.gsub(/[^0-9a-zA-Z]/i, '') }"}.join(' ')
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
    Revival.revive!([], self) 
  end

end