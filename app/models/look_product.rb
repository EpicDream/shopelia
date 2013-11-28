class LookProduct < ActiveRecord::Base
  belongs_to :look
  belongs_to :product

  validates :look_id, :presence => true
  validates :product_id, :presence => true

  attr_accessible :look_id, :product_id, :url
  attr_accessor :url

  before_validation :check_url_validity, if:Proc.new{ |item| item.url.present? }
  before_validation :find_or_create_product, if:Proc.new{ |item| item.url.present? && item.errors.empty? }
  after_create :generate_event

  private

  def check_url_validity
    raise if self.url !~ /^http/
    URI.parse(self.url)
    rescue
      self.errors.add(:base, I18n.t('app.collections.add.invalid_url'))
  end

  def find_or_create_product
    self.product_id = Product.fetch(self.url).id
  end

  def generate_event
    self.product.authorize_push_channel
    EventsWorker.perform_async({
      :product_id => self.product_id,
      :action => Event::REQUEST,
      :tracker => "look"
    }) if self.product.merchant.mapping_id.present?
  end
end