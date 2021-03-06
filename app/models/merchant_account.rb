class MerchantAccount < ActiveRecord::Base

  EMAIL_DOMAIN = "shopelia.com"

  belongs_to :user
  belongs_to :merchant
  belongs_to :address
  has_many :orders
  
  validates :user, :presence => true
  validates :merchant, :presence => true
  validates :login, :presence => true, :uniqueness => { :scope => :merchant_id }
  validates :password, :presence => true
  
  before_validation :attribute_login
  before_validation :attribute_password
  before_validation :attribute_address
  after_create :create_email_redirection
  after_destroy :destroy_email_redirection
  
  attr_accessible :user_id, :merchant_id, :address_id, :login, :is_default

  before_validation do |record|
    record.is_default = true if record.is_default.nil?
  end

  before_destroy do |record|
    if MerchantAccount.where("user_id=? and merchant_id=? and id<>? and is_default='t'", record.user_id, record.merchant_id, record.id).count == 0
      default_account = MerchantAccount.where("user_id=? and merchant_id=? and id<>?", record.user_id, record.merchant_id, record.id).first
      default_account.update_attribute :is_default, true unless default_account.nil?
    end
    Order.running.where(merchant_account_id:record.id).each do |order|
      order.reject "merchant_account_destroyed"
    end
  end
  
  after_save do |record|
    if record.is_default?
      if self.merchant.multiple_addresses?
        MerchantAccount.where("user_id=? and merchant_id=? and id<>? and is_default='t'", record.user_id, record.merchant_id, record.id).update_all "is_default='f'"
      else
        MerchantAccount.where("user_id=? and merchant_id=? and address_id=? and id<>? and is_default='t'", record.user_id, record.merchant_id, record.address_id, record.id).update_all "is_default='f'"
      end
    end
  end

  def self.find_or_create_for_order order
    if order.merchant.present? && order.merchant.multiple_addresses?
      MerchantAccount.where("user_id=? and merchant_id=? and is_default='t'", order.user_id, order.merchant_id).first || MerchantAccount.create(user_id:order.user_id, merchant_id:order.merchant_id)
    else      
      MerchantAccount.where("user_id=? and merchant_id=? and address_id=? and is_default='t'", order.user_id, order.merchant_id, order.address_id).first || MerchantAccount.create(user_id:order.user_id, merchant_id:order.merchant_id, address_id:order.address_id)
    end
  end
  
  def confirm_creation!
    self.update_attribute :merchant_created, true
  end
  
  private

  def create_email_redirection
    user_name = self.login.gsub(/\@.*$/, "")
    EmailRedirection.find_or_create_by_user_name_and_destination(:user_name => user_name, :destination => self.user.email)
  end
  
  def destroy_email_redirection
    if MerchantAccount.where(:login => self.login).count == 0
      user_name = self.login.gsub(/\@.*$/, "")
      EmailRedirection.where(:user_name => user_name).destroy_all
    end
  end
  
  def attribute_login
    if self.login.nil?
      base_login = self.user.email.downcase.gsub("@", ".")
      login = "#{base_login}@#{EMAIL_DOMAIN}"
      i = 2
      login = "#{base_login}.#{i}@#{EMAIL_DOMAIN}" and i += 1 until MerchantAccount.where(:merchant_id => self.merchant_id, :login => login).count == 0
      self.login = login
    end    
  end
  
  def attribute_password
    self.password = SecureRandom.hex(4) if self.password.nil?
  end
  
  def attribute_address
    self.address_id = self.user.addresses.default.first.try(:id) if self.address_id.nil? && !self.merchant.multiple_addresses?
  end    
end