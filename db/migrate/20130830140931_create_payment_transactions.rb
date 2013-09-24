class CreatePaymentTransactions < ActiveRecord::Migration
  def change
    create_table :payment_transactions do |t|
      t.integer :order_id
      t.string :processor
      t.integer :mangopay_amazon_voucher_id
      t.string :mangopay_amazon_voucher_code

      t.timestamps
    end
  end
end
