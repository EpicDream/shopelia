class Activity < ActiveRecord::Base
  attr_accessible :flinker_id, :resource_id
  
  belongs_to :flinker
end