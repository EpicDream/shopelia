class CollectionItem < ActiveRecord::Base
  belongs_to :collection
  belongs_to :product_version
  belongs_to :user
  has_one :product, :through => :product_version

  validates :collection_id, :presence => true
  validates :product_version_id, :presence => true, :uniqueness => { :scope => :collection_id }

  attr_accessible :collection_id, :product_version_id, :url
  attr_accessor :url

  before_validation :check_url_validity, if:Proc.new{ |item| item.url.present? }
  before_validation :find_or_create_product, if:Proc.new{ |item| item.url.present? && item.errors.empty? }

  private

  def check_url_validity
    raise if self.url !~ /^http/
    URI.parse(self.url)
    rescue
      self.errors.add(:base, I18n.t('app.collections.add.invalid_url'))
  end
  
  def find_or_create_product
    product = Product.fetch(self.url)
    self.product_version_id = product.product_versions.first.id
  end
end