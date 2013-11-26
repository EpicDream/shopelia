class AddVirtualCardIdToPaymentTransactions < ActiveRecord::Migration
  def change
    add_column :payment_transactions, :virtual_card_id, :integer
  end
end
