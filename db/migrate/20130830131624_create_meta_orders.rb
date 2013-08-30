class CreateMetaOrders < ActiveRecord::Migration
  def change
    create_table :meta_orders do |t|
      t.integer :user_id

      t.timestamps
    end
  end
end
