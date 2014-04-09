require 'flink/algolia'

class Hashtag < ActiveRecord::Base
  include Algolia::HashtagSearch unless Rails.env.test?
  
  attr_accessible :name
  
  validates :name, presence:true, uniqueness:true
  before_validation :hashtagify
  
  def hashtagify
    self.name = self.name.gsub(/[^[[:alnum:]]]/, '').unaccent if self.name
  end
  
end