class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :token_authenticatable
  devise :recoverable, :rememberable, :trackable, :validatable, :confirmable

  before_save :ensure_authentication_token

  has_many :addresses
  has_many :phones

  validates :first_name, :presence => true
  validates :last_name, :presence => true

  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name
end
