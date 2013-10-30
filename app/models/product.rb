class Product < ActiveRecord::Base
  include AlgoliaSearch

  VERSIONS_EXPIRATION_DELAY_IN_HOURS = 4

  belongs_to :product_master
  belongs_to :merchant
  has_many :events, :dependent => :destroy
  has_many :product_versions, :dependent => :destroy
  has_and_belongs_to_many :developers, :uniq => true
  
  validates :merchant, :presence => true
  validates :product_master, :presence => true
  validates :url, :presence => true, :uniqueness => true
  
  before_validation :clean_url
  before_validation :extract_merchant_from_url
  before_validation :create_product_master
  before_save :truncate_name
  after_save :create_versions
  after_save :clear_failure_if_mute, :if => Proc.new { |product| product.mute? }
  
  attr_accessible :versions, :merchant_id, :url, :name, :description
  attr_accessible :product_master_id, :image_url, :versions_expires_at
  attr_accessible :brand, :reference, :viking_failure, :muted_until
  attr_accessible :options_completed, :viking_sent_at, :batch
  attr_accessor :versions, :batch
  
  scope :viking_pending, lambda { joins(:events).merge(Event.buttons).merge(Product.viking_base_request) }
  scope :viking_pending_batch, lambda { joins(:events).merge(Event.requests).merge(Product.viking_base_request) }
  scope :viking_failure, lambda { where(viking_failure:true).order("updated_at desc").limit(100) }
  scope :expired, where("versions_expires_at is null or versions_expires_at < ?", Time.now)

  scope :viking_base_request, lambda {
    where("(products.versions_expires_at is null or products.versions_expires_at < ?)" +
      "and events.created_at > ? and (muted_until is null or muted_until < ?) " +
      "and products.viking_sent_at is null", Time.now, 12.hours.ago, Time.now).order("events.created_at desc").limit(100)
  }
  
  algoliasearch index_name: "products-#{Rails.env}" do
    attribute :name, :description, :url, :image_url, :brand, :reference
    attributesToIndex [:name, :brand, :description]
  end

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
    !self.viking_failure && self.versions_expires_at.present? && self.versions_expires_at > Time.now
  end

  def available?
    self.product_versions.available.count > 0
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
  
  def create_versions
    if self.versions.present?
      self.versions.each do |version|
        version[:price_text] = version[:price]
        version[:price_shipping_text] = version[:price_shipping]
        version[:price_strikeout_text] = version[:price_strikeout]
        version[:availability_text] = version[:availability]
        version[:shipping_info] = version[:availability] if version[:shipping_info].blank?
        [:price, :price_shipping, :price_strikeout, :availability].each { |k| version.delete(k) }

        # Pre-process versions
        version = MerchantHelper.process_version(self.url, version)

        if version[:option1] || version[:option2] || version[:option3] || version[:option4]
          v = self.product_versions.where(
            option1_md5:nil,
            option2_md5:nil,
            option3_md5:nil,
            option4_md5:nil).first
        end

        v ||= self.product_versions.where(
          option1_md5:ProductVersion.generate_option_md5(version[:option1]),
          option2_md5:ProductVersion.generate_option_md5(version[:option2]),
          option3_md5:ProductVersion.generate_option_md5(version[:option3]),
          option4_md5:ProductVersion.generate_option_md5(version[:option4])).first
        if v.nil?
          v = ProductVersion.create!(version.merge({product_id:self.id}))
        else
          # reset values
          v.update_attributes(
            :price => nil,
            :price_shipping => nil,
            :price_strikeout => nil,
            :description => nil,
            :image_url => nil,
            :images => nil,
            :available => nil,
            :name => nil,
            :shipping_info => nil)
          v.update_attributes version
        end
      end
      version = self.reload.product_versions.available.order(:updated_at).first
      if version.present?
        self.update_column "name", version.name
        self.update_column "brand", version.brand
        self.update_column "reference", version.reference
        self.update_column "image_url", version.image_url
        self.update_column "description", version.description
      end
      self.update_column "versions_expires_at", Product.versions_expiration_date
      self.reload
      self.assess_versions
      self.reload
      notify_channel
    elsif self.product_versions.empty?
      ProductVersion.create!(product_id:self.id,available:false)
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

  def notify_channel
    ts = Nest.new("product")[self.id][:created_at].get.to_i  
    Pusher.trigger("product-#{self.id}", "update", ProductSerializer.new(self).as_json[:product]) if ts > Time.now.to_i - 60*5
    rescue
  end
end
