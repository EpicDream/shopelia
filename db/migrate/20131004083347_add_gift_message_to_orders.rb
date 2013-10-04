class AddGiftMessageToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :gift_message, :text
  end
end
