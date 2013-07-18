class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer :action
      t.string :tracker
      t.string :user_agent
      t.string :ip_address
      t.string :visitor
      t.integer :developer_id
      t.integer :product_id
      t.integer :user_id
      t.timestamps
    end
  end
end
