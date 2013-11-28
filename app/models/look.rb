class Look < ActiveRecord::Base
  belongs_to :flinker
  belongs_to :post
  has_many :look_images, :foreign_key => "resource_id"

  validates :uuid, :presence => true, :uniqueness => true
  validates :flinker, :presence => true
  validates :name, :presence => true
  validates :url, :presence => true, :format => {:with => /\Ahttp/}
  validates :published_at, :presence => true

  before_validation :generate_uuid

  attr_accessible :flinker_id, :name, :url, :published_at

  private

  def generate_uuid
    self.uuid = SecureRandom.hex(4) if self.uuid.nil?
  end
end