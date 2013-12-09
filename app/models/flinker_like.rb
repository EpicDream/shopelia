class FlinkerLike < ActiveRecord::Base
  PRODUCT = "product"
  LOOK = "look"

  belongs_to :flinker

  validates :flinker_id, :presence => true
  validates :resource_type, :presence => true, :inclusion => { :in => [ PRODUCT, LOOK ] }
  validates :resource_id, :presence => true, :uniqueness => { :scope => [:flinker_id, :resource_type]}

  attr_accessible :flinker_id, :resource_id, :resource_type
end