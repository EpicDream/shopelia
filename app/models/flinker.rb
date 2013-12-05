class Flinker < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable

  before_save :ensure_authentication_token

  validates :email, :presence => true
  validates :username, length:{minimum:2}, allow_nil: true
  validates_confirmation_of :password

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username
  attr_accessible :name, :url

  has_attached_file :avatar, :url => "/images/flinker/:id/avatar.jpg", :path => "#{Rails.public_path}/images/flinker/:id/img.jpg"
end
