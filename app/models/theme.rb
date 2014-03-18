class Theme < ActiveRecord::Base
  attr_accessible :title, :rank
  
  has_and_belongs_to_many :looks
  has_and_belongs_to_many :flinkers
  has_and_belongs_to_many :hashtags
  
  has_one :theme_cover
end