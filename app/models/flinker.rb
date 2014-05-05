require 'flink/algolia'

class Flinker < ActiveRecord::Base
  include Algolia::FlinkerSearch unless Rails.env.test? #algolia webmock does not mock http request at all.
  
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username
  attr_accessible :name, :url, :is_publisher, :avatar_url, :country_id, :staff_pick
  attr_accessible :country_iso, :universal, :lang_iso, :verified
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
  after_create :follow_staff_picked
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
  scope :universals, where(universal:true)
  scope :with_username_like, ->(username) { where('username like ?', "#{username}%") unless username.blank? }
  scope :with_blog_matching, ->(pattern) {
    publishers.joins(:blog).where('blogs.url ~* ? or blogs.name ~* ?', pattern, pattern) unless pattern.blank?
  }
  scope :likes, ->(flinker){
    where(id:flinker.id)
    .joins(:looks)
    .joins('join flinker_likes on flinker_likes.resource_id = looks.id')
  }
  
  def name=name
    write_attribute(:name, name)
    self.blog.update_attributes(name:name) if self.blog
  end
  
  def followings
    Flinker.joins('join flinker_follows on flinkers.id = flinker_follows.follow_id')
    .where('flinker_follows.flinker_id = ?', self.id)
  end
  
  def followers
    Flinker.joins('join flinker_follows on flinkers.id = flinker_follows.flinker_id')
    .where('flinker_follows.follow_id = ?', self.id)
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
  
  def self.similar_to flinker
    similars = Flinker.find_by_sql(FlinkerSql.similarities(flinker, 10))
    offset = 10 - similars.count
    last = Flinker.find_by_sql(FlinkerSql.flinker_last_registered_order_by_likes(10 + offset))
    similars.shuffle + last.shuffle
  end
  
  def self.top_likers_of_publisher_of_look look
    Flinker.find_by_sql FlinkerSql.top_likers_of_publisher_of_look(look)
  end
  
  private
  
  def assign_uuid
    self.uuid = SecureRandom.hex(4)
  end
  
  def set_avatar
    self.avatar = URI.parse(self.avatar_url) if self.avatar_url.present?
  end

  def follow_staff_picked
    country = self.country.try(:iso)
    country = Country::FRANCE if !country || Flinker.publishers.staff_pick.of_country(country).count.zero?
    flinkers = Flinker.publishers.staff_pick.of_country_or_universal(country).limit(25)
    flinkers.each do |flinker|
      FlinkerFollow.create(flinker_id:self.id, follow_id:flinker.id, skip_notification:true)
    end
  end

end
