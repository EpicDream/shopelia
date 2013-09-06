class AddAvailabilityInfoToProductVersions < ActiveRecord::Migration
  def change
    add_column :product_versions, :availability_info, :string
  end
end
