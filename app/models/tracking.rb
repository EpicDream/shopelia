class Tracking < ActiveRecord::Base
  SEE_LOOK = "seelook"
  CLICK_BLOG = "clickblog"
  SEE_ALL = "seeall"
  NOTIFICATION = "openpush"
  
  attr_accessible *column_names
  
  validates :look_uuid, presence:true, unless: -> { self.notification? }

  scope :between, ->(after_date, before_date) { where(created_at: after_date..before_date) }
  scope :for_publisher, ->(publisher_id) { where(publisher_id: publisher_id) }
  scope :for_look, ->(look_uuid) { where(look_uuid: look_uuid) }
  scope :event, ->(event) { where(event: event) }
  
  def notification?
    event == NOTIFICATION
  end
end