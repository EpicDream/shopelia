class FlinkerLike < ActiveRecord::Base
  PRODUCT = "product"
  LOOK = "look"
  
  act_as_flink_activity :like

  attr_accessible :flinker_id, :resource_id, :resource_type

  belongs_to :flinker
  belongs_to :look, foreign_key: :resource_id, class_name:'Look'

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
  
  def product?
    resource_type == PRODUCT
  end
  
  def look?
    resource_type == LOOK
  end
  
end
