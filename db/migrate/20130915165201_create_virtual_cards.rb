class CreateVirtualCards < ActiveRecord::Migration
  def change
    create_table :virtual_cards do |t|
      t.string :provider
      t.string :number
      t.string :exp_month
      t.string :exp_year
      t.string :cvv
      t.float :amount
      t.integer :cvd_id

      t.timestamps
    end
  end
end
