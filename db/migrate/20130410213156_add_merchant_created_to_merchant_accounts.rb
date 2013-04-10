class AddMerchantCreatedToMerchantAccounts < ActiveRecord::Migration
  def change
    add_column :merchant_accounts, :merchant_created, :boolean, :default => false
  end
end
