class Tag < ActiveRecord::Base
  has_and_belongs_to_many :collections

  validates :name, :presence => true, :uniqueness => true

  attr_accessible :name
end
