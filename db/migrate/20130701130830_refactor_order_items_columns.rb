class RefactorOrderItemsColumns < ActiveRecord::Migration
  def up
    rename_column :order_items, :delivery_text, :shipping_info
    rename_column :order_items, :price_delivery, :shipping_price
    rename_column :order_items, :price_product, :product_price
  end

  def down
    rename_column :order_items, :shipping_info, :delivery_text
    rename_column :order_items, :shipping_price, :price_delivery
    rename_column :order_items, :product_price, :price_product
  end
end
