require 'flink/algolia'

class Hashtag < ActiveRecord::Base
  include Algolia::HashtagSearch unless Rails.env.test?
  
  attr_accessible :name
  
  has_and_belongs_to_many :looks
  
  validates :name, presence:true, uniqueness:true
  before_validation :hashtagify
  
  def hashtagify
    self.name = self.name.gsub(/[^[[:alnum:]]]/, '').unaccent if self.name
  end
  
end