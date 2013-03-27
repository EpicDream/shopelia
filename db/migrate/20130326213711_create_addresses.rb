class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.integer :user_id
      t.string :code_name
      t.string :address1
      t.string :address2
      t.string :zip
      t.string :city
      t.integer :state_id
      t.integer :country_id
      t.boolean :is_default

      t.timestamps
    end
  end
end
