class AddColumnsToBillingTransactions < ActiveRecord::Migration
  def change
    add_column :billing_transactions, :mangopay_source_wallet_id, :integer
  end
end
