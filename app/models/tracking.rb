class Tracking < ActiveRecord::Base
  attr_accessible *column_names
  
  validates :look_uuid, presence:true
  
end