class AddMerchantAccountIdToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :merchant_account_id, :integer
  end
end
