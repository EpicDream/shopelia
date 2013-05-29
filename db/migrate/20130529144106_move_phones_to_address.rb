class MovePhonesToAddress < ActiveRecord::Migration
  def up
    drop_table :phones
    add_column :addresses, :phone, :string
    add_column :addresses, :first_name, :string
    add_column :addresses, :last_name, :string
  end

  def down
    create_table :phones do |t|
      t.integer :user_id
      t.integer :address_id
      t.string :number
      t.integer :line_type
      t.timestamps
    end    
    remove_column :addresses, :phone
    remove_column :addresses, :first_name
    remove_column :addresses, :last_name
  end
end
