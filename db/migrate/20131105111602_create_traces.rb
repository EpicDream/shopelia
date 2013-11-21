class CreateTraces < ActiveRecord::Migration
  def change
    create_table :traces do |t|
      t.integer :user_id
      t.integer :device_id
      t.string :ressource
      t.string :action
      t.integer :extra_id
      t.string :extra_text
      t.string :ip_address

      t.timestamps
    end
  end
end
