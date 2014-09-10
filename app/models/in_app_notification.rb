class InAppNotification < ActiveRecord::Base
  TARGETS = ["Look", "Flinker", "Hashtag", "Theme"]
  
  belongs_to :image
  
  validates :title, presence:true
  validates :subtitle, presence:true
  validates :content, presence:true
  validates :button_title, presence:true
  validates :image, presence:true
  
  before_save :find_resource_id, unless: -> { self.resource_identifier.blank? }
  
  accepts_nested_attributes_for :image, allow_destroy: true
  
  scope :prepublications, -> { where(preproduction: true) }
  scope :publications, -> { where(production: true) }
  scope :published_or_prepublished, -> { where('preproduction = ? or production = ?', true, true) }
  scope :archives, -> { where(production: false, preproduction: false)}
  scope :country, -> (lang_iso){
    lang_iso == 'fr_FR' ? where(lang: 'fr') : where(lang: 'en')
  }
  scope :builds, ->(build) { 
    if build
      where('(max_build is null and min_build is null) or
       ((min_build <= :build or min_build is null) and (max_build >= :build or max_build is null))', build: build)
    end
  }
  scope :available, -> { where('expire_at::DATE >= ?', Time.now.utc)}
  scope :ordered, -> { order('priority desc, created_at desc')}
  
  def self.notifications_for flinker
    if Device.developer?(flinker)
      published_or_prepublished.filtered(flinker)
    else
      publications.filtered(flinker)
    end
  end
  
  def self.filtered flinker
    country(flinker.lang_iso)
    .builds(flinker.device.try(:build))
    .available
    .ordered
  end
  
  private
  
  def find_resource_id
    self.resource_id = case self.resource_klass_name
    when "Look" then Look.with_uuid(self.resource_identifier).first.id
    when "Hashtag" then Hashtag.find_or_create_by_name(self.resource_identifier).id
    when "Flinker" then Flinker.find(self.resource_identifier).id
    when "Theme" then nil
    end
  end
  
end