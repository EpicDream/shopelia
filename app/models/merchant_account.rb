class MerchantAccount < ActiveRecord::Base
  belongs_to :user
  belongs_to :merchant
  
  validates :user, :presence => true
  validates :merchant, :presence => true
  validates :login, :presence => true, :uniqueness => { :scope => :merchant_id }
  validates :password, :presence => true
  
  attr_accessible :user_id, :merchant_id, :login, :password, :is_default

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
    
end
