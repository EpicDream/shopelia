class FlinkerLike < ActiveRecord::Base
  PRODUCT = "product"
  LOOK = "look"

  attr_accessible :flinker_id, :resource_id, :resource_type

  belongs_to :flinker

  validates :flinker_id, :presence => true
  validates :resource_type, :presence => true, :inclusion => { :in => [ PRODUCT, LOOK ] }
  validates :resource_id, :presence => true, :uniqueness => { :scope => [:flinker_id, :resource_type]}

  scope :top_likers, ->(max=20, since=Date.parse("2014-01-01")) { 
    where('created_at >= ?', since)
    .includes(:flinker)
    .group('flinker_id')
    .select('flinker_id, count(*)')
    .limit(max)
    .order('count(*) desc')
  }
end
