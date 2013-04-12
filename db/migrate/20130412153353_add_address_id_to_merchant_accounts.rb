class AddAddressIdToMerchantAccounts < ActiveRecord::Migration
  def change
    add_column :merchant_accounts, :address_id, :integer
  end
end
