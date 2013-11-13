class Collection < ActiveRecord::Base
  belongs_to :user
  has_many :collection_items, :dependent => :destroy
  has_many :collection_tags, :dependent => :destroy
  has_many :products, :through => :collection_items
  has_many :tags, :through => :collection_tags

  validates :uuid, :presence => true, :uniqueness => true

  before_validation :generate_uuid
  before_validation :generate_rank
  after_save :set_home_tag

  has_attached_file :image, :url => "/images/collections/:id/img.jpg", :path => "#{Rails.public_path}/images/collections/:id/img.jpg"
  after_post_process :save_image_dimensions

  attr_accessible :description, :name, :user_id, :public, :image, :rank

  scope :public, where(public:true)

  def to_param
    param = self.uuid + (self.name.present? ? "-#{self.name}" : "")
    param.unaccent.parameterize
  end

  def belongs_to? user
    user && self.user_id == user.id
  end

  def items
    self.products.available
  end

  private

  def generate_uuid
    self.uuid = SecureRandom.hex(4) if self.uuid.nil?
  end

  def generate_rank
    self.rank = 1 if self.public? && self.rank.nil?
  end

  def save_image_dimensions
    geo = Paperclip::Geometry.from_file(image.queued_for_write[:original])
    self.image_size = "#{geo.width.to_i}x#{geo.height.to_i}"
  end

  def set_home_tag
    if self.public_changed?
      if self.public?
        self.tags << Tag.find_by_name("__Home")
      else
        self.tags.where(name:"__Home").destroy_all
      end
    end
  end
end