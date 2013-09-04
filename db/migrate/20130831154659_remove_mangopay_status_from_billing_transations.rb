class RemoveMangopayStatusFromBillingTransations < ActiveRecord::Migration
  def up
    remove_column :billing_transactions, :mangopay_contribution_status
  end

  def down
    add_column :billing_transactions, :mangopay_contribution_status, :string
  end
end
