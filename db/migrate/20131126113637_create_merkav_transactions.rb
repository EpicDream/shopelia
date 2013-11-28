class CreateMerkavTransactions < ActiveRecord::Migration
  def change
    create_table :merkav_transactions do |t|
      t.integer :virtual_card_id
      t.string :token
      t.string :optkey
      t.integer :amount
      t.datetime :executed_at
      t.string :status
      t.integer :merkav_transaction_id

      t.timestamps
    end
  end
end
