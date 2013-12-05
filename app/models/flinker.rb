class Flinker < ActiveRecord::Base
  has_many :looks

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable

  before_save :ensure_authentication_token

  validates :email, :presence => true
  validates :username, length:{minimum:2}, allow_nil: true
  validates_confirmation_of :password

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username
  attr_accessible :name, :url, :is_publisher

  has_attached_file :avatar, :url => "/images/flinker/:id/avatar.jpg", :path => "#{Rails.public_path}/images/flinker/:id/img.jpg"
end
