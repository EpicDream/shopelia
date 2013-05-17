class AddPaymentCardItToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :payment_card_id, :integer
  end
end
