class Trace < ActiveRecord::Base
  belongs_to :device
  belongs_to :user

  validates :device, :presence => true
  validates :resource, :presence => true
  validates :action, :presence => true
  validates :ip_address, :presence => true

  attr_accessible :resource, :action, :device_id, :extra_id, :extra_text, :user_id, :ip_address

  before_validation :retrieve_product
  after_create :update_user_session
  after_create :notify_push_channel, :if => Proc.new { |trace| trace.device.push_channel_authorized? }

  private

  def retrieve_product
    if self.resource == 'Product' && self.extra_text.present? && self.extra_text =~ /^Ahttp/
      p = Product.fetch(self.extra_text)
      self.extra_id = p.id
      self.extra_text = nil
    end
  end

  def update_user_session
    current_session = device.user_sessions.order(:updated_at).last
    if current_session && current_session.active?
      current_session.touch
    else
      UserSession.create(device_id:self.device_id, user_id:self.user_id)
    end
  end

  def notify_push_channel
     Pusher.trigger("device-#{self.device_id}", "trace", {id:self.id})
  end
end
