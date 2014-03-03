class Flinker < ActiveRecord::Base
  include RankedModel
  
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username
  attr_accessible :name, :url, :is_publisher, :avatar_url, :country_id, :staff_pick
  attr_accessible :display_order_position, :country_iso, :universal, :lang_iso
  attr_accessor :avatar_url, :country_iso

  devise :database_authenticatable, :registerable, :recoverable
  devise :rememberable, :trackable, :validatable, :token_authenticatable

  has_attached_file :avatar, 
                    :styles => { thumb:["200x200>", :jpg] },
                    :url  => "/images/flinker/:id/:style/avatar.jpg",
                    :path => ":rails_root/public/images/flinker/:id/:style/avatar.jpg"

  ranks :display_order

  has_many :looks
  has_many :comments
  has_many :flinker_authentications
  has_many :flinker_likes
  has_many :devices, dependent: :destroy
  has_many :flinker_follows, include: :following
  belongs_to :country
  has_one :blog

  before_save :ensure_authentication_token
  before_create :country_from_iso_code, unless: -> { self.country_iso.blank? }
  after_create :follow_staff_picked
  before_validation :set_avatar
  after_create :leftronic_flinkers_count
  after_destroy :leftronic_flinkers_count
  
  validates :email, :presence => true
  validates :username, uniqueness:true, allow_nil: true
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
  
  private
  
  def set_avatar
    self.avatar = URI.parse(self.avatar_url) if self.avatar_url.present?
  end

  def follow_staff_picked
    country = self.country.try(:iso)
    country = Country::FRANCE if !country || Flinker.publishers.staff_pick.of_country(country).count.zero?
    flinkers = Flinker.publishers.staff_pick.of_country_or_universal(country).limit(25)
    flinkers.each do |flinker|
      FlinkerFollow.create(flinker_id:self.id, follow_id:flinker.id)
    end
  end

  def leftronic_flinkers_count
    LeftronicLiveFlinkersWorker.perform_async
  end

end
