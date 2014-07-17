class FlinkerLike < ActiveRecord::Base
  PRODUCT = "product"
  LOOK = "look"
  default_scope where(on:true)
  
  act_as_flink_activity :like
  
  attr_accessible :flinker_id, :resource_id, :resource_type, :on

  belongs_to :flinker
  belongs_to :look, foreign_key: :resource_id, class_name: 'Look'
  
  validates :flinker_id, :presence => true
  validates :resource_type, :presence => true, :inclusion => { :in => [ PRODUCT, LOOK ] }
  validates :resource_id, :presence => true, :uniqueness => { :scope => [:flinker_id, :resource_type]}
  
  scope :likes_for, ->(flinkers, type=LOOK) {
    flinkers = [flinkers].flatten
    where(flinker_id:flinkers.map(&:id), resource_type:type)
  }
  
  scope :liked_for, ->(flinker, type=LOOK) {
    where(resource_type:type).joins(:look).where('looks.flinker_id = ?', flinker.id)
  }
  
  scope :liked_by_friends, ->(flinker, look) {
    likes_for(flinker.friends).where(resource_id:look.id)
  }
  
  scope :of_look, ->(look) { where(resource_id: look.id, resource_type: LOOK) }
  scope :of_flinker, ->(flinker) { where(flinker_id: flinker.id) }
  
  def product?
    resource_type == PRODUCT
  end
  
  def look?
    resource_type == LOOK
  end
  
  def self.toggle_or_create flinker, look
    like = self.unscoped { of_flinker(flinker).of_look(look).first }
    if like
      like.update_attributes(on: !like.on)
    else
      create(flinker_id:flinker.id, resource_type:LOOK, resource_id:look.id)
    end
  end
  
end
