class Tag < ActiveRecord::Base
  has_many :collection_tags
  has_many :collections, :through => :collection_tags

  validates :name, :presence => true, :uniqueness => true

  attr_accessible :name
end
