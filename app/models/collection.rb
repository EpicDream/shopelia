class Collection < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :product_versions
  has_and_belongs_to_many :tags

  validates :user, :presence => true
  validates :uuid, :presence => true, :uniqueness => true

  before_validation :generate_uuid

  attr_accessible :description, :name, :user_id

  def to_param
    param = self.uuid + (self.name.present? ? "-#{self.name}" : "")
    param.unaccent.parameterize
  end

  private

  def generate_uuid
    self.uuid = SecureRandom.hex(4) if self.uuid.nil?
  end
end