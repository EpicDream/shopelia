class StaffHashtag < ActiveRecord::Base
  attr_accessible *column_names
  
  validates :name_en, presence:true, uniqueness:true
  validates :name_fr, presence:true, uniqueness:true
  
  scope :visible, -> { where(visible:true) }
  scope :invisible, -> { where(visible:false) }
  
  def self.grouped_by_category
    invisible.group_by(&:category)
  end
  
  def self.categories
    select('distinct(category)').order('category desc').map(&:category)
  end
  
end