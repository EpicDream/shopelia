class Message < ActiveRecord::Base
  attr_accessible :content, :data, :device_id, :from_admin, :read , :products_urls
  serialize :data, Array
  belongs_to :device
  before_save :serialize_data

  attr_accessor :products_urls


  private

  def serialize_data
    unless self.products_urls.nil?
       self.data =  self.products_urls.split(/\r?\n/).reject! { |c| c.empty? }
    end
  end

end



