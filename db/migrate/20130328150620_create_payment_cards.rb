class CreatePaymentCards < ActiveRecord::Migration
  def change
    create_table :payment_cards do |t|
      t.integer :user_id
      t.string :name
      t.string :number
      t.string :exp_month
      t.string :exp_year
      t.string :cvv

      t.timestamps
    end
  end
end
