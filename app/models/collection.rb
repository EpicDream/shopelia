class Collection < ActiveRecord::Base
  belongs_to :user
  has_many :collection_items, :dependent => :destroy
  has_many :collection_tags, :dependent => :destroy
  has_many :products, :through => :collection_items
  has_many :tags, :through => :collection_tags

  validates :user, :presence => true
  validates :name, :presence => true
  validates :uuid, :presence => true, :uniqueness => true

  before_validation :generate_uuid

  attr_accessible :description, :name, :user_id, :public, :image

  has_attached_file :image, :url => "/images/collections/:id/img.jpg", :path => "#{Rails.public_path}/images/collections/:id/img.jpg"

  def to_param
    param = self.uuid + (self.name.present? ? "-#{self.name}" : "")
    param.unaccent.parameterize
  end

  def belongs_to? user
    self.user_id == user.id
  end

  def size
    self.collection_items.count
  end

  def items
    self.collection_items.order("collection_items.created_at ASC")
  end

  private

  def generate_uuid
    self.uuid = SecureRandom.hex(4) if self.uuid.nil?
  end
end