require 'flink/algolia'

class Flinker < ActiveRecord::Base
  include Algolia::FlinkerSearch unless Rails.env.test?
  FLINK_HQ_USERNAME = "flinkhq"
  
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :can_comment, :city, :area
  attr_accessible :name, :url, :is_publisher, :avatar_url, :country_id, :staff_pick, :timezone, :newsletter
  attr_accessible :country_iso, :universal, :lang_iso, :verified, :last_session_open_at, :last_revival_at
  attr_accessor :avatar_url, :country_iso

  devise :database_authenticatable, :registerable, :recoverable
  devise :rememberable, :trackable, :validatable, :token_authenticatable

  has_attached_file :avatar, 
                    :styles => { thumb:["200x200>", :jpg] },
                    :url  => "/images/flinker/:id/:style/avatar.jpg",
                    :path => ":rails_root/public/images/flinker/:id/:style/avatar.jpg"

  has_many :looks, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :flinker_authentications, dependent: :destroy
  has_many :flinker_likes, dependent: :destroy
  has_many :facebook_friends, dependent: :destroy
  has_many :devices, dependent: :destroy
  has_many :flinker_follows, include: :following, dependent: :destroy
  belongs_to :country
  has_one :blog, dependent: :destroy

  before_save :ensure_authentication_token
  before_create :country_from_iso_code, unless: -> { self.country_iso.blank? }
  before_create :assign_uuid
  after_create :signup_welcome
  
  before_validation :set_avatar
  before_destroy ->(record) {
    Activity.where(target_id:record.id).destroy_all
    FlinkerFollow.where(follow_id:record.id).destroy_all
    FacebookFriend.where(friend_flinker_id:record.id).destroy_all
  }
  
  validates :email, :presence => true
  validates :username, uniqueness:{ case_sensitive: false }, allow_nil: true
  validates_format_of :username, with: /^[\w\d\._-]{2,}$/, allow_nil: true
  validates_confirmation_of :password
  validates_attachment :avatar, :content_type => { :not => [:html] }
    
  scope :publishers, where(is_publisher:true)
  scope :of_country, ->(iso) { !iso.blank? && joins(:country).where('countries.iso' => iso.upcase) }
  scope :of_country_or_universal, ->(iso) { 
    unless iso.blank?
      joins(:country).where('countries.iso = ? or flinkers.universal = ?', iso.upcase, true) 
    else
      self.universals
    end
  }
  scope :with_looks, where("looks_count > 0")
  scope :staff_pick, ->(staff_pick=true) { where(staff_pick:staff_pick)}
  scope :staff_picked_countries, -> {
    staff_pick
    .joins(:country)
    .group('countries.name')
    .select('countries.name, count(*)')
  }
  
  scope :universals, where(universal:true)
  scope :with_username_like, ->(username) { where('username like ?', "#{username}%") unless username.blank? }
  scope :with_blog_matching, ->(pattern) {
    publishers.joins(:blog).where('blogs.url ~* ? or blogs.name ~* ?', pattern, pattern) unless pattern.blank?
  }
  scope :likes, ->(flinker){
    where(id:flinker.id)
    .joins(:looks)
    .joins('join flinker_likes on flinker_likes.resource_id = looks.id')
    .where('flinker_likes.on = ?', true)
  }
  scope :with_location, -> { where('city is not null or area is not null') }

  scope :followings_between, ->(from, to) {
    from ||= Rails.configuration.min_date
    to ||= Time.now
    
    where('flinker_follows.updated_at >= ? and flinker_follows.updated_at <= ?', from, to)
  }
  
  alias_attribute :publisher, :is_publisher
  
  def name=name
    write_attribute(:name, name)
    self.blog.update_attributes(name:name) if self.blog
  end
  
  def followings
    Flinker.joins('join flinker_follows on flinkers.id = flinker_follows.follow_id')
    .where('flinker_follows.flinker_id = ? and flinker_follows.on = ?', self.id, true)
    .select('flinkers.*, EXTRACT(EPOCH FROM flinker_follows.updated_at) as follow_updated_at')
  end
  
  def unfollowings
    Flinker.joins('join flinker_follows on flinkers.id = flinker_follows.follow_id')
    .where('flinker_follows.flinker_id = ? and flinker_follows.on = ?', self.id, false)
    .select('flinkers.*, EXTRACT(EPOCH FROM flinker_follows.updated_at) as follow_updated_at')
  end
  
  def followers
    Flinker.joins('join flinker_follows on flinkers.id = flinker_follows.flinker_id')
    .where('flinker_follows.follow_id = ? and flinker_follows.on = ?', self.id, true)
  end
  
  def device
    devices.last
  end
  
  def country_from_iso_code
    self.country = Country.where(iso:self.country_iso.upcase).first
  end
  
  def friends
    followings | FacebookFriend.of_flinker(self).flinkers.map(&:friend)
  end
  
  def activities_counts
    @activities_counts ||= Hash[connection.execute(ActivitySql.counts(self)).first.collect {|k,v| [k, v.to_i] }]
  end
  
  def publisher_without_looks?
    self.is_publisher? && self.looks.published.count.zero?
  end
  
  def cover_image
    look = self.looks.published.order('flink_published_at desc').limit(1).first
    look && look.image_for_cover
  end
  
  def english_language?
    lang_iso != "fr_FR"
  end
  
  def cover_images n=3
    looks = self.looks.published.order('flink_published_at desc').limit(n)
    looks.map { |look|  
      look.image_for_cover.picture.url(:small)
    }
  end
  
  def self.similar_to flinker
    similars = Flinker.find_by_sql(FlinkerSql.similarities(flinker, 10))
    offset = 10 - similars.count
    last = Flinker.find_by_sql(FlinkerSql.flinker_last_registered_order_by_likes(10 + offset))
    similars.shuffle + last.shuffle
  end
  
  def self.top_likers_of_publisher_of_look look
    Flinker.find_by_sql FlinkerSql.top_likers_of_publisher_of_look(look)
  end
  
  def self.recommendations_for flinker, total=3
    key = ActiveSupport::Cache.expand_cache_key([:flinker, :recommendations_for, flinker.id])
    Rails.cache.fetch(key, expires_in: 3.days) do
      similars = similar_to(flinker)
      likes = similars.map { |f| FlinkerLike.where(resource_type:FlinkerLike::LOOK, flinker_id:f.id).last }
      flinkers = likes.map(&:look).map(&:flinker).uniq
      flinkers.first(total)
    end
  end
  
  def self.flinkHQ
    Flinker.where(username:FLINK_HQ_USERNAME).first
  end
  
  def self.top_liked from, max=20, exclusion=[]
    Flinker.find_by_sql FlinkerSql.top_liked(from, max, exclusion)
  end
  
  def self.trend_setters country=nil
    country ||= Country.us
    skope = publishers.staff_pick
    iso = skope.of_country(country.iso).first.nil? ? Country::US : country.iso 
    total = skope.of_country(iso).count
    exclusion = skope.of_country(iso).map(&:id)
    skope.of_country(iso) + top_liked(Date.today - 1.week, 20 - total, exclusion)
  end

  def trackable_url
    uri = Addressable::URI.parse(self.url)
    uri.query_values ||= {}
    uri.query_values = uri.query_values.merge({utm_source:'flink-web', utm_medium:'website'})
    uri.to_s
  end

  private
  
  def assign_uuid
    self.uuid = SecureRandom.hex(4)
  end
  
  def set_avatar
    self.avatar = URI.parse(self.avatar_url) if self.avatar_url.present?
  end

  def signup_welcome
    self.touch(:last_revival_at)
  end

end
