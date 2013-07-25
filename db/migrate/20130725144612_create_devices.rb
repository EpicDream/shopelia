class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :uuid
      t.text :user_agent

      t.timestamps
    end
    add_index :devices, :uuid
  end
end
