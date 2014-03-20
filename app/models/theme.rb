class Theme < ActiveRecord::Base
  attr_accessible :title, :rank, :theme_cover_attributes
  
  has_and_belongs_to_many :looks
  has_and_belongs_to_many :flinkers
  has_and_belongs_to_many :hashtags
  has_one :theme_cover, foreign_key: :resource_id, dependent: :destroy
  
  validates :title, presence:true
  
  before_create :assign_default_rank
  
  accepts_nested_attributes_for :theme_cover
  
  private
  
  def assign_default_rank
    self.rank = Theme.count + 1
  end
  
end