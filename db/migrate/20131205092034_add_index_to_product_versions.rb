class AddIndexToProductVersions < ActiveRecord::Migration
  def change
    add_index :product_versions, [:product_id, :available]
  end
end
