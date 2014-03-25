class Theme < ActiveRecord::Base
  acts_as_list
  
  attr_accessible :title, :rank, :theme_cover_attributes, :hashtags_attributes, :published, :position
  attr_accessor :theme_cover_attributes
  
  has_and_belongs_to_many :looks
  has_and_belongs_to_many :flinkers
  has_and_belongs_to_many :hashtags
  has_one :theme_cover, foreign_key: :resource_id, dependent: :destroy
  
  before_create :assign_default_cover, unless: -> { self.theme_cover }
  before_validation :remove_blanks_hashtags
  
  accepts_nested_attributes_for :theme_cover
  accepts_nested_attributes_for :hashtags
  
  scope :published, ->(published) { where(published:published) }

  #uniq => true seems not work on many to many with rails 3, so we use uniq index
  def append_look look
    self.looks << look rescue PG::UniqueViolation 
    self.flinkers << look.flinker rescue PG::UniqueViolation
  end
  
  def remove_look look
    self.looks.destroy(look)
    if self.looks_of_flinker(look.flinker).count.zero?
      self.flinkers.destroy(look.flinker)
    end
  end
  
  def looks_of_flinker flinker
    looks.where(flinker_id: flinker.id)
  end
  
  private

  #to avoid validation error if hashtag blank, while not creating blank hashtags, another way ?
  def remove_blanks_hashtags 
    self.hashtags.delete_if { |hashtag| hashtag.name.blank?  }
  end
  
  def assign_default_cover
    self.theme_cover = ThemeCover.default.dup
    self.theme_cover.save!
  end
  
end