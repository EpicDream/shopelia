class Collection < ActiveRecord::Base
  belongs_to :user
  has_many :collection_items
  has_many :collection_tags
  has_many :product_versions, :through => :collection_items
  has_many :tags, :through => :collection_tags

  validates :user, :presence => true
  validates :name, :presence => true
  validates :uuid, :presence => true, :uniqueness => true

  before_validation :generate_uuid

  attr_accessible :description, :name, :user_id

  scope :items, joins(:collection_items).order("collection_items.created_at ASC")

  def to_param
    param = self.uuid + (self.name.present? ? "-#{self.name}" : "")
    param.unaccent.parameterize
  end

  def belongs_to? user
    self.user_id == user.id
  end

  private

  def generate_uuid
    self.uuid = SecureRandom.hex(4) if self.uuid.nil?
  end
end