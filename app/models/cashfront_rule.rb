class CashfrontRule < ActiveRecord::Base
  belongs_to :merchant
  belongs_to :developer

  validates :merchant_id, :presence => true, :uniqueness => { :scope => :developer_id }
  validates :rebate_percentage, :presence => true, :inclusion => 1..10

  attr_accessible :category_id, :developer_id, :max_rebate_value, :merchant_id, :rebate_percentage, :user_id

  scope :for_developer, lambda { |developer| where(developer_id:developer.id) }

  def rebate price
    r = price * self.rebate_percentage / 100.0
    if self.max_rebate_value.present?
      r > self.max_rebate_value ? self.max_rebate_value : r
    else
      r
    end
  end
end
