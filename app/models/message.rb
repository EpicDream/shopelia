class Message < ActiveRecord::Base
  attr_accessible :content, :data, :device_id, :from_admin, :pending_answer, :read
  serialize :data, Array
  belongs_to :device



  def self.last_messages
    messages = []
    Device.joins(:messages).where("messages.pending_answer=?", true).uniq.each do |device|
      messages << device.messages.last  unless device.messages.last.nil?
    end
    messages
  end



end



