require 'flink/algolia'

class Hashtag < ActiveRecord::Base
  include Algolia::HashtagSearch unless Rails.env.test?
  
  attr_accessible :name
  
  has_and_belongs_to_many :looks
  
  validates :name, presence:true, uniqueness:true
  before_validation :hashtagify
  
  scope :matching, ->(name) { where('name ~* ?', "^#{Hashtag.hashtagify(name)}$").limit(1) }
  
  def hashtagify
    self.name = Hashtag.hashtagify(self.name)
  end
  
  def self.hashtagify string
    string.gsub(/[^[[:alnum:]]]/, '').unaccent if string
  end
  
  def self.find_or_create_by_name string
    name = hashtagify(string)
    Hashtag.matching(name).first || create(name:name)
  end
  
  def self.update_with_name old_name, new_name
    hashtag, new_hashtag = [old_name, new_name].map { |name| Hashtag.matching(name).first }
    if new_hashtag
      new_hashtag.looks << hashtag.looks and hashtag.destroy
    else
      hashtag and hashtag.update_attributes(name:new_name)
    end
  end
  
  def self.find_or_create_from_strings strings
    strings.map { |string| find_or_create_by_name(string)}
  end
  
  def self.create_hashtags_from_staff_hashtags look, staff_hashtags_ids
    hashtags = StaffHashtag.find(staff_hashtags_ids).map { |tag|
      [tag.name_en, tag.name_fr].map {|name| 
        hashtag = Hashtag.find_or_create_by_name(name)
        HighlightedLook.create(look_id: look.id, hashtag_id:hashtag.id) if tag.visible?
        hashtag
      }.uniq
    }.flatten
    
    look.hashtags << hashtags
  end
  
end