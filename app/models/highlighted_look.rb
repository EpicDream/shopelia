class HighlightedLook < ActiveRecord::Base
  belongs_to :look
  belongs_to :hashtag
  
  def self.hashtags_of_look look
    Hashtag.where(id:where(look_id:look.id).map(&:hashtag_id))
  end
  
  def self.hashtags
    Hashtag.where(id:all.map(&:hashtag_id))
  end
  
  def self.looks_of_hashtag hashtag
    Look.where(id:where(hashtag_id:hashtag.id).map(&:look_id))
  end
  
  def self.highlight? look, hashtag
    !!where(look_id:look.id, hashtag_id:hashtag.id).first
  end
end