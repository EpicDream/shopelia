class CreateMerchantAccounts < ActiveRecord::Migration
  def change
    create_table :merchant_accounts do |t|
      t.integer :user_id
      t.integer :merchant_id
      t.string :login
      t.string :password
      t.boolean :is_default

      t.timestamps
    end
  end
end
