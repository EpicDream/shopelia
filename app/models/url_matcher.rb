class UrlMatcher < ActiveRecord::Base
  validates :url, :presence => true, :uniqueness => true
  validates :canonical, :presence => true
  
  attr_accessible :canonical, :url
  
  before_validation do |record|
    !record.url.eql?(record.canonical)
  end
end
