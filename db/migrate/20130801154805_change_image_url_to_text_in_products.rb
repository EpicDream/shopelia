class ChangeImageUrlToTextInProducts < ActiveRecord::Migration
  def up
    change_column :products, :image_url, :text
    change_column :product_versions, :size, :text
    change_column :product_versions, :color, :text
  end

  def down
    change_column :products, :image_url, :string
    change_column :product_versions, :size, :string
    change_column :product_versions, :color, :string
  end
end
