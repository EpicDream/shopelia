class UserSession < ActiveRecord::Base
  belongs_to :device
  belongs_to :user

  validates :device, :presence => true

  attr_accessible :device_id, :user_id

  def active?
    self.updated_at.to_i > Time.now.to_i - 30.minutes.to_i
  end
end