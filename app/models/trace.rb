class Trace < ActiveRecord::Base
  belongs_to :device
  belongs_to :user

  validates :device, :presence => true
  validates :resource, :presence => true
  validates :action, :presence => true
  validates :ip_address, :presence => true

  attr_accessible :resource, :action, :device_id, :extra_id, :extra_text, :user_id, :ip_address

  after_create :update_user_session

  private

  def update_user_session
    current_session = device.user_sessions.order(:updated_at).last
    if current_session && current_session.active?
      current_session.touch
    else
      UserSession.create(device_id:self.device_id, user_id:self.user_id)
    end
  end
end