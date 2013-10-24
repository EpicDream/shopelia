class Message < ActiveRecord::Base
  attr_accessible :content, :data, :device_id, :from_admin, :read , :products_urls
  serialize :data, Array
  belongs_to :device
  before_save :serialize_data

  attr_accessor :products_urls


  private

  def serialize_data
    p self.products_urls
    unless self.products_urls.nil?

    end
  end

end



