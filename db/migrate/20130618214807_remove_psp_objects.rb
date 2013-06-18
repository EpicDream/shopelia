class RemovePspObjects < ActiveRecord::Migration
  def up
    drop_table :psp_users
    drop_table :psp_payment_cards
    drop_table :psps
    add_column :users, :leetchi_id, :integer
    add_column :users, :leetchi_created_at, :datetime
    add_column :payment_cards, :leetchi_id, :integer
    add_column :payment_cards, :leetchi_created_at, :datetime
  end

  def down
    create_table :psps do |t|
      t.string :name
      t.timestamps
    end
    create_table :psp_users do |t|
      t.integer :user_id
      t.integer :psp_id
      t.integer :remote_user_id
      t.timestamps
    end
    create_table :psp_payment_cards do |t|
      t.integer :payment_card_id
      t.integer :psp_id
      t.integer :remote_payment_card_id
      t.timestamps
    end
    remove_column :users, :leetchi_id
    remove_column :users, :leetchi_created_at
    remove_column :payment_cards, :leetchi_id
    remove_column :payment_cards, :leetchi_created_at
  end
end
