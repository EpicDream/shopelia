class AddColumnsToPaymentTransactions < ActiveRecord::Migration
  def change
    add_column :payment_transactions, :amount, :integer
    add_column :payment_transactions, :mangopay_source_wallet_id, :integer
  end
end
