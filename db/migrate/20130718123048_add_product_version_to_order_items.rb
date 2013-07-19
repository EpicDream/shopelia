class AddProductVersionToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :product_version_id, :integer
    
    OrderItem.all.each do |item|
      product = Product.find_by_id(item.product_id)
      next if product.nil?
      version = product.product_versions.first!
      item.product_version_id = version.id
      item.save!
    end
    
    remove_column :order_items, :product_id
  end
end
