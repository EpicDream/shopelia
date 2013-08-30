class MetaOrder < ActiveRecord::Base
  belongs_to :user
  has_many :orders, :dependent => :destroy

  validate :user, :presence => true

  attr_accessible :user_id
end
