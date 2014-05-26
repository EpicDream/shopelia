class CreatePrivateMessages < ActiveRecord::Migration
  def change
    create_table :private_messages, :force => true do |t|
      t.text :content
      t.integer :flinker_id
      t.integer :target_id
      t.integer :look_id
      t.timestamps
    end
    add_index :private_messages, :flinker_id
    add_index :private_messages, :target_id
  end
end