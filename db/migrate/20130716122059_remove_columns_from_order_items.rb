class RemoveColumnsFromOrderItems < ActiveRecord::Migration
  def change
    remove_column :order_items, :price_text
    remove_column :order_items, :shipping_info
    remove_column :order_items, :shipping_price
    remove_column :order_items, :product_title
    remove_column :order_items, :product_image_url
    rename_column :order_items, :product_price, :price
  end
end
