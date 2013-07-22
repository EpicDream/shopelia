class AddAvailableToProductVersions < ActiveRecord::Migration
  def change
    add_column :product_versions, :available, :boolean
  end
end
