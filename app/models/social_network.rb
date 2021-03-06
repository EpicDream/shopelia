class SocialNetwork < ActiveRecord::Base
  FACEBOOK = "facebook"
  TWITTER = "twitter"
  MAIL = "mail"
  OPEN_POST = "openpost"
  
  attr_accessible :name
  
  validates :name, :presence => true, :uniqueness => true
  scope :with_name, ->(name) { where(name:name).limit(1) }
  
  def self.twitter
    with_name(TWITTER)
  end
  
  def self.facebook
    with_name(FACEBOOK)
  end
end
