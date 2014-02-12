class Flinker < ActiveRecord::Base
  include RankedModel

  has_many :looks
  has_many :comments
  has_many :flinker_authentications
  has_many :flinker_likes
  has_many :flinker_follows
  belongs_to :country
  has_one :blog
  
  devise :database_authenticatable, :registerable, :recoverable
  devise :rememberable, :trackable, :validatable, :token_authenticatable

  before_save :ensure_authentication_token
  before_create :country_from_iso_code, unless: -> { self.country_iso.blank? }
  after_create :follow_staff_picked
  after_create :leftronic_flinkers_count
  after_destroy :leftronic_flinkers_count
  
  validates :email, :presence => true
  validates :username, length:{minimum:2}, allow_nil: true, uniqueness:true
  validates_confirmation_of :password
  before_validation :set_avatar

  has_attached_file :avatar, 
                    :styles => { thumb:["200x200>", :jpg] },
                    :url  => "/images/flinker/:id/:style/avatar.jpg",
                    :path => ":rails_root/public/images/flinker/:id/:style/avatar.jpg"

  ranks :display_order
  
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
  scope :staff_pick, where(staff_pick:true)
  scope :universals, where(universal:true)
  
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username
  attr_accessible :name, :url, :is_publisher, :avatar_url, :country_id, :staff_pick
  attr_accessible :display_order_position, :country_iso, :universal
  attr_accessor :avatar_url, :country_iso

  def name=name
    write_attribute(:name, name)
    self.blog.update_attributes(name:name) if self.blog
  end
  
  private
  
  def country_from_iso_code
    self.country = Country.where(iso:self.country_iso.upcase).first
  end
  
  def set_avatar
    self.avatar = URI.parse(self.avatar_url) if self.avatar_url.present?
  end

  def follow_staff_picked
    flinkers = Flinker.publishers.staff_pick.of_country_or_universal(self.country.try(:iso)).limit(25)
    flinkers.each do |flinker|
      FlinkerFollow.create(flinker_id:self.id, follow_id:flinker.id)
    end
  end

  def leftronic_flinkers_count
    Leftronic.new.notify_flinkers_count
  end

end
