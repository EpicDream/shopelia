class Flinker < ActiveRecord::Base
  has_many :looks
  has_many :flinker_authentications
  has_many :flinker_likes
  has_many :flinker_follows

  devise :database_authenticatable, :registerable, :recoverable
  devise :rememberable, :trackable, :validatable, :token_authenticatable

  before_save :ensure_authentication_token

  validates :email, :presence => true
  validates :username, length:{minimum:2}, allow_nil: true
  validates_confirmation_of :password
  before_validation :reset_test_account

  has_attached_file :avatar, 
                    :styles => { thumb:["200x200>", :jpg] },
                    :url  => "/images/flinker/:id/:style/avatar.jpg",
                    :path => ":rails_root/public/images/flinker/:id/:style/avatar.jpg"

  attr_accessible :email, :password, :password_confirmation, :remember_me, :username
  attr_accessible :name, :url, :is_publisher

  private

  def reset_test_account
    if self.email.eql?("test@flink.io")
      user = Flinker.find_by_email("test@flink.io")
      user.destroy unless user.nil?
    end
  end
end