class ModifyLeechiColumns < ActiveRecord::Migration
  def up
    remove_column :users, :leetchi_created_at
    remove_column :payment_cards, :leetchi_created_at
    add_column :orders, :leetchi_wallet_id, :integer
    add_column :orders, :leetchi_contribution_id, :integer
    add_column :orders, :leetchi_contribution_status, :string
    add_column :orders, :leetchi_contribution_amount, :integer
  end

  def down
    add_column :users, :leetchi_created_at, :timestamp
    add_column :payment_cards, :leetchi_created_at, :timestap
    remove_column :orders, :leetchi_wallet_id
    remove_column :orders, :leetchi_contribution_id
    remove_column :orders, :leetchi_contribution_status
    remove_column :orders, :leetchi_contribution_amount
  end
end
