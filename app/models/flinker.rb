class Flinker < ActiveRecord::Base
  include AlgoliaSearch
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
  after_create :follow_staff_picked

  validates :email, :presence => true
  validates :username, length:{minimum:2}, allow_nil: true
  validates_confirmation_of :password
  before_validation :reset_test_account
  before_validation :set_avatar

  has_attached_file :avatar, 
                    :styles => { thumb:["200x200>", :jpg] },
                    :url  => "/images/flinker/:id/:style/avatar.jpg",
                    :path => ":rails_root/public/images/flinker/:id/:style/avatar.jpg"

  ranks :display_order

  attr_accessible :email, :password, :password_confirmation, :remember_me, :username
  attr_accessible :name, :url, :is_publisher, :avatar_url, :country_id, :staff_pick
  attr_accessible :display_order_position
  attr_accessor :avatar_url

  algoliasearch index_name: "flinkers-#{Rails.env}" do
    attribute :name, :username, :url
    attributesToIndex [:name, :username, :url, :avatar_url]
  end
  
  def url=url
    write_attribute(:url, url)
    self.blog.update_attributes(url:url) if self.blog
  end
  
  def name=name
    write_attribute(:name, name)
    self.blog.update_attributes(name:name) if self.blog
  end
  
  def self.coordinates #TODO set lat,lng via rake task and use it instead of cache
    Rails.cache.fetch(:"flinkers-coordinates", expires_in:1.day ) {
      coords = proc { |record| Geocoder.coordinates(record['last_sign_in_ip']) }
      Flinker.connection.execute('select last_sign_in_ip from flinkers where last_sign_in_ip is not null').map(&coords)
    }
  end

  private

  def set_avatar
    self.avatar = URI.parse(self.avatar_url) if self.avatar_url.present?
  end

  def reset_test_account
    if self.email.eql?("test@flink.io")
      user = Flinker.find_by_email("test@flink.io")
      user.destroy unless user.nil?
    end
  end

  def follow_staff_picked
    Flinker.where(is_publisher:true,staff_pick:true).each do |flinker|
      FlinkerFollow.create(flinker_id:self.id,follow_id:flinker.id)
    end
  end

end