class Theme < ActiveRecord::Base
  acts_as_list
  
  attr_accessible :title, :rank, :published, :position, :subtitle, :cover_height
  attr_accessible :theme_cover_attributes, :hashtags_attributes
  attr_accessor :theme_cover_attributes
  
  has_and_belongs_to_many :looks
  has_and_belongs_to_many :flinkers
  has_and_belongs_to_many :hashtags
  has_one :theme_cover, foreign_key: :resource_id, dependent: :destroy
  
  before_create :assign_default_cover, unless: -> { self.theme_cover }
  before_validation :find_or_create_hashtag
  
  accepts_nested_attributes_for :theme_cover
  accepts_nested_attributes_for :hashtags, allow_destroy: true, reject_if: ->(attributes) { attributes['name'].blank? }
  
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
  
  def medaillon
    looks.first && looks.last.look_images.first && looks.last.look_images.first.picture.url(:small)
  end
  
  def append_flinker flinker
    self.flinkers << flinker rescue PG::UniqueViolation
    self.looks << flinker.looks - looks_of_flinker(flinker)
  end
  
  def remove_flinker flinker
    self.flinkers.destroy(flinker)
    self.looks.destroy(flinker.looks)
  end
  
  def title_for_display
    title.scan(/>(.*?)<\/style>/).flatten.join if title
  end
  
  private
  
  def find_or_create_hashtag
    self.hashtags = self.hashtags.map { |hashtag|  
      if hashtag.new_record?
        Hashtag.find_by_name(hashtag.name) || hashtag
      else
        hashtag
      end
    }
  end
  
  def assign_default_cover
    self.theme_cover = ThemeCover.default.dup
    self.theme_cover.save!
  end
  
end