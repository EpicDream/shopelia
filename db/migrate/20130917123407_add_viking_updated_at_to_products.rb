class AddVikingUpdatedAtToProducts < ActiveRecord::Migration
  def change
    add_column :products, :viking_updated_at, :timestamp
  end
end
