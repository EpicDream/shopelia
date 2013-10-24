class Message < ActiveRecord::Base
  belongs_to :device

  before_validation :ensure_device_pushable
  before_save :serialize_data
  after_create :set_pending_answer
  after_create :notify

  serialize :data, Array

  validates :device, :presence => true

  attr_accessible :content, :data, :device_id, :read, :products_urls, :from_admin
  attr_accessor :products_urls

  private

  def set_pending_answer
    self.device.update_attribute :pending_answer, !self.from_admin?
  end

  def serialize_data
    self.data =  self.products_urls.split(/\r?\n/).compact if self.products_urls.present?
  end

  def ensure_device_pushable
    self.errors.add(:base, I18n.t('messages.errors.device_not_pushable')) unless self.device.push_token.present?
  end

  def notify
    if self.from_admin?
      Push.send_message(self)
    else
      Emailer.notify_admin_new_message_to_george(self).deliver
    end
  end
end