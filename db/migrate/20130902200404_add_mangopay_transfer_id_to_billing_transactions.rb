class AddMangopayTransferIdToBillingTransactions < ActiveRecord::Migration
  def change
    add_column :billing_transactions, :mangopay_transfer_id, :integer
    remove_column :billing_transactions, :mangopay_source_wallet_id
  end
end
