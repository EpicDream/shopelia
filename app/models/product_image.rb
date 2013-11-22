class ProductImage < ActiveRecord::Base
  belongs_to :product_version

  validates :product_version, :presence => true
  validates :url, :presence => true

  before_validation :set_image_size

  attr_accessible :product_version_id, :size, :url

  private

  def set_image_size
    self.size = ImageSizeProcessor.get_image_size(self.url)
  end
end