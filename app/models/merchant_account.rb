class MerchantAccount < ActiveRecord::Base

  EMAIL_DOMAIN = "shopelia.fr"

  belongs_to :user
  belongs_to :merchant
  belongs_to :address
  
  validates :user, :presence => true
  validates :merchant, :presence => true
  validates :login, :presence => true, :uniqueness => { :scope => :merchant_id }
  validates :password, :presence => true
  validates :address, :presence => true
  
  before_validation :attribute_login
  before_validation :attribute_password
  before_validation :attribute_address
  
  attr_accessible :user_id, :merchant_id, :address_id, :login, :is_default

  before_validation do |record|
    record.is_default = true  if MerchantAccount.where(:user_id => record.user_id, :merchant_id => record.merchant_id).count == 0
  end

  before_destroy do |record|
    if MerchantAccount.where("user_id=? and merchant_id=? and id<>? and is_default='t'", record.user_id, record.merchant_id, record.id).count == 0
      default_account = MerchantAccount.where("user_id=? and merchant_id=? and id<>?", record.user_id, record.merchant_id, record.id).first
      default_account.update_attribute :is_default, true unless default_account.nil?
    end
  end
  
  after_save do |record|
    MerchantAccount.where("user_id=? and merchant_id=? and id<>? and is_default='t'", record.user_id, record.merchant_id, record.id).update_all "is_default='f'" if record.is_default?
  end
  
  def self.find_or_create user, merchant
    MerchantAccount.where("user_id=? and merchant_id=? and is_default='t'", user.id, merchant.id).first || MerchantAccount.create(user_id:user.id, merchant_id:merchant.id)
  end
  
  private
  
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
    self.address_id = self.user.addresses.default.first.try(:id)
  end
    
end
