class CreateBillingTransactions < ActiveRecord::Migration
  def change
    create_table :billing_transactions do |t|
      t.integer :meta_order_id
      t.integer :user_id
      t.string :processor
      t.integer :amount
      t.boolean :success
      t.integer :mangopay_contribution_id
      t.integer :mangopay_contribution_amount
      t.string :mangopay_contribution_status
      t.string :mangopay_contribution_message
      t.integer :mangopay_destination_wallet_id

      t.timestamps
    end
  end
end
