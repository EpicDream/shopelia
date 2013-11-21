class AddProductsCountToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :products_count, :integer
  end
end
