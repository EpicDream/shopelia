class CashfrontRule < ActiveRecord::Base
  belongs_to :merchant
  belongs_to :developer
  belongs_to :device

  validates :merchant_id, :presence => true, :uniqueness => { :scope => [:developer_id, :device_id] }
  validates :device_id, :allow_nil => true, :uniqueness => { :scope => [:developer_id, :merchant_id] }
  validates :rebate_percentage, :presence => true, :inclusion => 1..100

  attr_accessible :category_id, :developer_id, :device_id, :user_id
  attr_accessible :max_rebate_value, :merchant_id, :rebate_percentage

  scope :for_merchant, lambda { |merchant| where(merchant_id:merchant.try(:id)) }
  scope :for_developer, lambda { |developer| where(developer_id:developer.try(:id)) }
  scope :for_device, lambda { |device| where(device_id:device.try(:id)) }
  scope :without_device, where("device_id is null")

  def self.find_for_scope scope={}
    rule_req = CashfrontRule.for_merchant(scope[:merchant]).for_developer(scope[:developer])
    if scope[:device].present?
      rule_req.send(:for_device, scope[:device]).first || rule_req.send(:without_device).first
    else
      rule_req.send(:without_device).first
    end
  end

  def rebate price
    r = price.to_f * self.rebate_percentage / 100.0
    if self.max_rebate_value.present?
      r = r > self.max_rebate_value ? self.max_rebate_value : r
    else
      r
    end
    r.round(2)
  end
end
