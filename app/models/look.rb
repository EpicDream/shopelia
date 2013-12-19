class Look < ActiveRecord::Base
  belongs_to :flinker
  has_one :post
  has_many :look_images, :foreign_key => "resource_id", :dependent => :destroy
  has_many :look_products, :dependent => :destroy
  has_many :products, :through => :look_products

  validates :uuid, :presence => true, :uniqueness => true, :on => :create
  validates :flinker, :presence => true
  validates :name, :presence => true
  validates :url, :presence => true, :format => {:with => /\Ahttp/}
  validates :published_at, :presence => true

  before_validation :generate_uuid

  attr_accessible :flinker_id, :name, :url, :published_at, :is_published

  def self.random
    offset(rand(Look.count)).limit(1).first
  end

  def mark_post_as_processed
    self.post.update_attributes(processed_at:Time.now)
  end

  def liked_by? flinker
    !FlinkerLike.where("flinker_id=? and resource_type=? and resource_id=?", flinker.id, FlinkerLike::LOOK, self.id).empty?
  end

  private

  def generate_uuid
    self.uuid = SecureRandom.hex(4) if self.uuid.blank?
  end
end