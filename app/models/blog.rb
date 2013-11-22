class Blog < ActiveRecord::Base
  attr_accessible :url
  
  validate :url, uniqueness:true, presence:true
end
