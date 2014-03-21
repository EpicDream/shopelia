class Theme < ActiveRecord::Base
  attr_accessible :title, :rank, :theme_cover_attributes, :hashtags_attributes
  attr_accessor :theme_cover_attributes
  
  has_and_belongs_to_many :looks
  has_and_belongs_to_many :flinkers
  has_and_belongs_to_many :hashtags
  has_one :theme_cover, foreign_key: :resource_id, dependent: :destroy
  
  before_create :assign_default_rank
  before_create :assign_default_cover, unless: -> { self.theme_cover }
  before_validation :remove_blanks_hashtags
  
  accepts_nested_attributes_for :theme_cover
  accepts_nested_attributes_for :hashtags
  
  private
  
  def remove_blanks_hashtags 
    #to avoid validation error if hashtag blank, while not creating blank hashtags, another way ?
    self.hashtags.delete_if { |hashtag| hashtag.name.blank?  }
  end
  
  def assign_default_rank
    self.rank = Theme.count + 1
  end
  
  def assign_default_cover
    self.theme_cover = ThemeCover.default.dup
    self.theme_cover.save!
  end
  
end