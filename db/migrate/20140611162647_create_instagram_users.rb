class CreateInstagramUsers < ActiveRecord::Migration
  def change
    create_table :instagram_users, :force => true do |t|
      t.references :flinker
      t.integer :instagram_id
      t.string :access_token
      t.timestamps
    end
    add_index :instagram_users, :flinker_id
    add_index :instagram_users, :instagram_id
  end
end