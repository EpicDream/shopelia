class ScanLog < ActiveRecord::Base
  belongs_to :device

  validates :device, :presence => true
  validates :ean, :presence => true
  validates :prices_count, :presence => true

  attr_accessible :device_id, :ean, :prices_count
end