class AddRatingToProductVersions < ActiveRecord::Migration
  def change
    add_column :product_versions, :rating, :float
  end
end
