class CreatePhones < ActiveRecord::Migration
  def change
    create_table :phones do |t|
      t.integer :user_id
      t.integer :address_id
      t.string :number
      t.integer :line_type

      t.timestamps
    end
  end
end
