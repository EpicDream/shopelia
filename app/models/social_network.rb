class SocialNetwork < ActiveRecord::Base
  attr_accessible :name
  
  validates :name, :presence => true, :uniqueness => true
  scope :with_name, ->(name) { where(name:name).limit(1) }
end
