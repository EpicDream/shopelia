class CreateTrackings < ActiveRecord::Migration
  def change
    create_table :trackings, :force => true do |t|
      t.string :look_uuid
      t.integer :publisher_id
      t.string :event
      t.integer :flinker_id
      t.string :device_uuid
      t.string :country_iso
      t.string :lang_iso
      t.string :timezone
      t.string :os
      t.string :os_version
      t.string :version
      t.string :build
      t.string :phone
      t.timestamps
    end
    add_index :trackings, :look_uuid
    add_index :trackings, :publisher_id
    add_index :trackings, :event
    add_index :trackings, [:publisher_id, :event]
  end
end