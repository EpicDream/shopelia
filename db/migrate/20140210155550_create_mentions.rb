class CreateMentions < ActiveRecord::Migration
  def change
    create_table :mentions, :force => true do |t|
      t.references :flinker
      t.references :comment
      t.integer :flinker_mentionned_id
      t.string :type
      t.timestamps
    end
    
    add_index :mentions, :flinker_id
    add_index :mentions, :type
  end
end