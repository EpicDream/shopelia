class InAppNotification < ActiveRecord::Base
  TARGETS = ["Look", "Flinker", "Hashtag", "Theme"]
  
  belongs_to :image
  
  scope :available_notifications_for, ->(flinker) {
    
  }
  
  accepts_nested_attributes_for :image, allow_destroy: true
  
end