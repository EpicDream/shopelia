class InAppNotification < ActiveRecord::Base
  TARGETS = ["Look", "Flinker", "Hashtag", "Theme"]
  
  belongs_to :image
  
  before_save :find_resource_id, unless: -> { self.resource_identifier.blank? }
  
  validates :title, presence:true
  validates :subtitle, presence:true
  validates :content, presence:true
  validates :button_title, presence:true
  
  accepts_nested_attributes_for :image, allow_destroy: true
  
  scope :available_notifications_for, ->(flinker) {
  }
  
  after_initialize ->(notif) {
    notif.image = Image.new if notif.image_id.nil?
  }
  
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