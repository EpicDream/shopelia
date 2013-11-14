class AddMappingRefToMerchant < ActiveRecord::Migration
  def change
    add_column :merchants, :mapping_id, :integer
    add_index :merchants, :mapping_id
  end
end
