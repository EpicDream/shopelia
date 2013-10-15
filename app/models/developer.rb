class Developer < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :confirmable
  devise :recoverable, :rememberable, :trackable, :validatable

  has_many :orders
  has_many :users
  has_many :events
  has_many :cart_items
  has_and_belongs_to_many :products, :uniq => true

  validates :email, :presence => true, :uniqueness => true
  validates :name, :presence => true, :uniqueness => true
  validates :api_key, :presence => true, :uniqueness => true, :length => { :is => 64 }
    
  attr_accessible :name, :api_key
  attr_accessible :email, :password, :password_confirmation, :remember_me
  
  before_validation do |record|
    record.api_key = SecureRandom.hex(32) unless record.api_key?
  end
end
