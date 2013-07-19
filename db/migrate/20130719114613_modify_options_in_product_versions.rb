class ModifyOptionsInProductVersions < ActiveRecord::Migration
  def change
    remove_column :product_versions, :options
    add_column :product_versions, :color, :string
    add_column :product_versions, :size, :string
    add_column :product_versions, :name, :string
    add_column :product_versions, :images, :string
  end
end
