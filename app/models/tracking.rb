class Tracking < ActiveRecord::Base
  SEE_LOOK = "seelook"
  CLICK_BLOG = "clickblog"
  SEE_ALL = "seeall"
  
  attr_accessible *column_names
  
  validates :look_uuid, presence:true

  scope :between, ->(after_date, before_date) { where(created_at: after_date..before_date) }
  scope :for_publisher, ->(publisher_id) { where(publisher_id: publisher_id) }
  scope :event, ->(event) { where(event: event) }
  
end