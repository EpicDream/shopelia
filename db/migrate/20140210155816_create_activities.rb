class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities, :force => true do |t|
      t.references :flinker
      t.integer :resource_id
      t.integer :target_id #flinker target of activity
      t.string :type
      t.timestamps 
    end
    
    add_index :activities, :flinker_id
    add_index :activities, :target_id
    add_index :activities, :type
  end
end