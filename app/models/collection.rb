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

  has_attached_file :image, :url => "/images/collections/:id/img.jpg", :path => "#{Rails.public_path}/images/collections/:id/img.jpg"
  after_post_process :save_image_dimensions

  attr_accessible :description, :name, :user_id, :public, :image

  scope :public, where(public:true)

  def to_param
    param = self.uuid + (self.name.present? ? "-#{self.name}" : "")
    param.unaccent.parameterize
  end

  def belongs_to? user
    user && self.user_id == user.id
  end

  def items
    self.products.available.order("collection_items.created_at ASC")
  end

  private

  def generate_uuid
    self.uuid = SecureRandom.hex(4) if self.uuid.nil?
  end

  def save_image_dimensions
    geo = Paperclip::Geometry.from_file(image.queued_for_write[:original])
    self.image_size = "#{geo.width}x#{geo.height}"
  end
end