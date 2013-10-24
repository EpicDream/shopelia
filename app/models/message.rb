class Message < ActiveRecord::Base
  belongs_to :device
  before_save :serialize_data
  after_create :set_pending_answer

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
end