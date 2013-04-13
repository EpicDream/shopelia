class AddPriceDeliveryToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :price_delivery, :float
    rename_column :order_items, :price_unit, :price_product
  end
end
