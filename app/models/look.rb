class Look < ActiveRecord::Base
  belongs_to :flinker
  has_one :post
  has_many :look_images, :foreign_key => "resource_id", :dependent => :destroy
  has_many :look_products, :dependent => :destroy

  validates :uuid, :presence => true, :uniqueness => true
  validates :flinker, :presence => true
  validates :name, :presence => true
  validates :url, :presence => true, :format => {:with => /\Ahttp/}
  validates :published_at, :presence => true

  before_validation :generate_uuid
  before_save :set_post_processed_at

  attr_accessible :flinker_id, :name, :url, :published_at, :is_published

  private

  def generate_uuid
    self.uuid = SecureRandom.hex(4) if self.uuid.blank?
  end

  def set_post_processed_at
    self.post.update_attributes(processed_at:Time.now) if self.is_published_changed? && self.post.present?
  end
end