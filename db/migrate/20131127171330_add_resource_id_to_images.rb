class AddResourceIdToImages < ActiveRecord::Migration
  def change
    add_column :images, :resource_id, :integer
  end
end
