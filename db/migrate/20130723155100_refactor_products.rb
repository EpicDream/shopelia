class RefactorProducts < ActiveRecord::Migration
  def change
    remove_column :products, :images
    remove_column :product_versions, :images
    add_column :product_versions, :image_url, :text
    add_column :product_versions, :brand, :string
  end
end
