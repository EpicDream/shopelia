class StaffHashtag < ActiveRecord::Base
  attr_accessible *column_names
  
  validates :name_en, presence:true, uniqueness:true
  validates :name_fr, presence:true, uniqueness:true
  
  scope :visible, -> { where(visible:true).order('name_en asc') }
  scope :invisible, -> { where(visible:false).order('name_en asc') }
  
  def self.grouped_by_category
    invisible.group_by(&:category)
  end
  
  def self.categories
    select('distinct(category)').order('category desc').map(&:category)
  end
  
end