class AddIndexesToEvents < ActiveRecord::Migration
  def change
    add_index :events, :product_id
    add_index :events, :device_id
    add_index :events, :developer_id
  end
end
