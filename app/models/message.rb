class Message < ActiveRecord::Base
  attr_accessible :content, :data, :device_id, :from_admin, :pending_answer, :read , :products_urls
  serialize :data, Array
  belongs_to :device
  before_save :serialize_data

  attr_accessor :products_urls



  def self.last_messages
    messages = []
    Device.joins(:messages).where("messages.pending_answer=?", true).uniq.each do |device|
      messages << device.messages.last  unless device.messages.last.nil?
    end
    messages
  end

  private

  def serialize_data
    p self.products_urls
    unless self.products_urls.nil?

    end
  end

end



