class CreatePspPaymentCards < ActiveRecord::Migration
  def change
    create_table :psp_payment_cards do |t|
      t.integer :payment_card_id
      t.integer :psp_id
      t.integer :remote_payment_card_id

      t.timestamps
    end
  end
end
