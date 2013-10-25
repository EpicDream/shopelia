class Message < ActiveRecord::Base
  belongs_to :device

  before_validation :ensure_content
  before_validation :ensure_device_pushable
  before_save :serialize_data
  after_create :set_pending_answer
  after_create :notify

  serialize :data, Array

  validates :device, :presence => true

  attr_accessible :content, :data, :device_id, :read, :products_urls, :from_admin
  attr_accessor :products_urls

  def build_push_data
    self.data.map do |url|
      product = Product.fetch(url)
      { product_url:product.url,
        name:product.name,
        image_url:product.image_url,
        price:product.product_versions.first.price }
    end
  end

  private

  def set_pending_answer
    self.device.update_attribute :pending_answer, !self.from_admin?
  end

  def serialize_data
    if self.products_urls.present?
      self.data =  self.products_urls.split(/\r?\n/).compact
      developer = Developer.find_by_name("Shopelia")
      self.data.each do |url|
        EventsWorker.perform_async({
          :url => url.unaccent,
          :developer_id => developer.id,
          :action => Event::REQUEST,
          :tracker => "georges",
          :device_id => self.device.id
        })
      end
    end
  end

  def ensure_content
    self.errors.add(:base, I18n.t('messages.errors.empty')) unless content.present? || products_urls.present?
  end

  def ensure_device_pushable
    self.errors.add(:base, I18n.t('messages.errors.device_not_pushable')) unless self.device.push_token.present?
  end

  def notify
    if self.from_admin?
      Push.send_message(self)
    else
      Emailer.notify_admin_new_message_to_george(self).deliver
    end
  end
end