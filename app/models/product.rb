class Product < ActiveRecord::Base
  belongs_to :product_master
  belongs_to :merchant
  has_many :events, :dependent => :destroy
  has_many :product_versions, :dependent => :destroy
  
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
  attr_accessible :options_completed
  attr_accessor :versions
  
  scope :viking_pending, lambda { 
    joins(:events).merge(Event.buttons) \
      .where("(products.versions_expires_at is null or (products.versions_expires_at < ? and products.viking_failure='f') " + 
      "or (products.versions_expires_at < ? and products.viking_failure='t')) and events.created_at > ? and " +
      "(muted_until is null or muted_until < ?)", Time.now, 6.hours.ago, 12.hours.ago, Time.now)
  }
  scope :viking_pending_batch, lambda { 
    joins(:events).merge(Event.requests) \
      .where("(products.versions_expires_at is null or (products.versions_expires_at < ? and products.viking_failure='f') " +
      "or (products.versions_expires_at < ? and products.viking_failure='t')) and events.created_at > ? and " +
      "(muted_until is null or muted_until < ?)", Time.now, 6.hours.ago, 12.hours.ago, Time.now) 
  }
  scope :viking_failure, lambda { where(viking_failure:true).order("updated_at desc").limit(100) }
  
  def self.fetch url
    Product.find_or_create_by_url(Linker.clean(url)) unless url.nil?
  end
  
  def self.viking_shift 
    Product.viking_pending.order("events.created_at desc").first
  end

  def self.viking_shift_batch
    Product.viking_pending_batch.order("events.created_at desc").first
  end

  def versions_expired?
    self.versions_expires_at.nil? || self.versions_expires_at < Time.now
  end
  
  def self.versions_expiration_date
    4.hours.from_now
  end
  
  def mute?
    self.muted_until.present? && self.muted_until > Time.now
  end
  
  def ready?
    !self.viking_failure && self.versions_expires_at.present? && self.versions_expires_at > Time.now
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
  
  def md5 hash
    hash.nil? ? nil : Digest::MD5.hexdigest(Hash[hash.sort].to_json)
  end

  def create_versions
    if self.versions.present?
      self.product_versions.update_all "available='f'"
      self.versions.each do |version|
        version[:price_text] = version[:price]
        version[:price_shipping_text] = version[:price_shipping]
        version[:price_strikeout_text] = version[:price_strikeout]
        version[:availability_text] = version[:availability]
        version[:shipping_info] = version[:availability] if version[:shipping_info].blank?
        [:price, :price_shipping, :price_strikeout, :availability].each { |k| version.delete(k) }

        # Default shipping values
        if version[:price_shipping_text].blank?
          m = MerchantConjurer.from_url(self.url)
          if m.present? && m.respond_to?('shipping_price')
            version[:price_shipping_text] = m.shipping_price(version[:price_text])
          end
        end

        v = self.product_versions.where(
          option1_md5:md5(version[:option1]),
          option2_md5:md5(version[:option2]),
          option3_md5:md5(version[:option3]),
          option4_md5:md5(version[:option4])).first
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
      version = self.reload.product_versions.where(available:true).order(:updated_at).first
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
  
end
