# -*- encoding : utf-8 -*-
class Product < ActiveRecord::Base

  VERSIONS_EXPIRATION_DELAY_IN_HOURS = 8

  belongs_to :product_master
  belongs_to :merchant
  has_many :events, :dependent => :destroy
  has_many :product_versions, :dependent => :destroy
  has_and_belongs_to_many :developers, :uniq => true
  has_many :collection_items
  has_many :collections, :through => :collection_items
  has_many :product_reviews
  
  validates :merchant, :presence => true
  validates :product_master, :presence => true
  validates :url, :presence => true, :uniqueness => true
  
  before_validation :clean_url
  before_validation :extract_merchant_from_url
  before_validation :create_product_master
  before_save :truncate_name
  after_save :clear_failure_if_mute, :if => Proc.new { |product| product.mute? }
  after_update :set_image_size, :if => Proc.new { |product| product.image_url_changed? || (product.image_url.present? && product.image_size.blank?) }
  
  attr_accessible :versions, :merchant_id, :url, :name, :description, :rating, :json_description
  attr_accessible :product_master_id, :image_url, :versions_expires_at
  attr_accessible :brand, :reference, :viking_failure, :muted_until
  attr_accessible :options_completed, :viking_sent_at, :batch
  attr_accessor :versions, :batch
  
  scope :viking_pending, lambda { joins(:events).merge(Event.buttons).merge(Product.viking_base_request) }
  scope :viking_pending_batch, lambda { joins(:events).merge(Event.requests).merge(Product.viking_base_request) }
  scope :viking_failure, lambda { where(viking_failure:true).order("updated_at desc").limit(100) }
  scope :expired, where("versions_expires_at is null or versions_expires_at < ?", Time.now)
  scope :available, joins(:product_versions).merge(ProductVersion.available).uniq

  scope :viking_base_request, lambda {
    where("(products.versions_expires_at is null or products.versions_expires_at < ?)" +
      "and events.created_at > ? and (muted_until is null or muted_until < ?) " +
      "and products.viking_sent_at is null", Time.now, 12.hours.ago, Time.now).order("events.created_at desc").limit(100)
  }
  
  def self.fetch url
    return nil if url.nil?
    p = Product.find_or_create_by_url(Linker.clean(url))
    p.save! if !p.persisted? && p.errors.empty?
    p.reload unless p.nil?
  end
  
  def versions_expired?
    self.versions_expires_at.nil? || self.versions_expires_at < Time.now
  end
  
  def self.versions_expiration_date
    VERSIONS_EXPIRATION_DELAY_IN_HOURS.hours.from_now
  end
  
  def viking_reset
    self.update_column "viking_sent_at", Time.now
    self.update_column "options_completed", false
    self.product_versions.update_all "available='f'"
    self
  end

  def mute?
    self.muted_until.present? && self.muted_until > Time.now
  end
  
  def ready?
    (self.merchant.present? && self.merchant.rejecting_events?) || self.viking_failure? || (self.versions_expires_at.present? && self.versions_expires_at > Time.now)
  end

  def available?
    self.product_versions.available.count > 0
  end

  def price
    version = self.product_versions.available.order("price_shipping + price").first
    version ? (version.price + version.price_shipping).to_f.round(2) : nil
  end

  def monetized_url
    UrlMonetizer.new.get(self.url)
  end

  def assess_versions
    ok = false
    self.product_versions.each do |version|
      ok = true if version.available == false \
        || (version.available \
        && version.name.present? \
        && version.price.present? \
        && version.price_shipping.present? \
        && version.image_url.present? \
        && version.shipping_info.present?)
    end
    self.update_column "viking_failure", !ok
  end
  
  def authorize_push_channel
    Nest.new("product")[self.id][:created_at].set(Time.now.to_i)
  end
  
  def has_review_for_author? author
    !!product_reviews.where(author:author).first
  end

  private
  
  def truncate_name
    self.name = self.name[0..249] if self.name && self.name.length > 250
  end
  
  def clean_url
    self.url = Linker.clean(self.url) unless self.url.nil?
  end
  
  def extract_merchant_from_url
    if self.merchant_id.nil? && self.url.present?
      merchant = Merchant.from_url(url)
      if merchant.nil?
        self.errors.add(:base, I18n.t('products.errors.invalid_url', :url => url))
      else
        self.merchant_id = merchant.id
      end
    end
  end
  
  def create_product_master
    self.product_master_id = ProductMaster.create.id if self.product_master_id.nil?
  end
  
  def set_viking_failure
    self.viking_failure = false if self.viking_failure.nil?
  end
  
  def clear_failure_if_mute
    self.update_column "viking_failure", false
    self.update_column "versions_expires_at", nil
  end

  def set_image_size
    size = ImageSizeProcessor.get_image_size(self.image_url)
    self.update_column "image_size", size unless size.nil?
  end

  def notify_channel
    ts = Nest.new("product")[self.id][:created_at].get.to_i  
    Pusher.trigger("product-#{self.id}", "update", ProductSerializer.new(self, scope:{short:true}).as_json[:product]) if ts > Time.now.to_i - 60*5
  rescue
  end
end
