class UrlMatcher < ActiveRecord::Base
  validates :url, :presence => true, :uniqueness => true
  validates :canonical, :presence => true
  
  attr_accessible :canonical, :url
end
