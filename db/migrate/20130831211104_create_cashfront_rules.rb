class CreateCashfrontRules < ActiveRecord::Migration
  def change
    create_table :cashfront_rules do |t|
      t.integer :merchant_id
      t.integer :category_id
      t.integer :developer_id
      t.integer :user_id
      t.float :rebate_percentage
      t.float :max_rebate_value

      t.timestamps
    end
  end
end
