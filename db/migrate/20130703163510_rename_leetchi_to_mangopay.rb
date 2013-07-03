class RenameLeetchiToMangopay < ActiveRecord::Migration
  def change
    rename_column :orders, :leetchi_wallet_id, :mangopay_wallet_id
    rename_column :orders, :leetchi_contribution_id, :mangopay_contribution_id
    rename_column :orders, :leetchi_contribution_status, :mangopay_contribution_status
    rename_column :orders, :leetchi_contribution_amount, :mangopay_contribution_amount
    rename_column :orders, :leetchi_contribution_message, :mangopay_contribution_message
    rename_column :users, :leetchi_id, :mangopay_id
    rename_column :payment_cards, :leetchi_id, :mangopay_id
  end
end

