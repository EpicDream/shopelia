class RenameVikingUpdatedAtInProducts < ActiveRecord::Migration
  def change
    rename_column :products, :viking_updated_at, :viking_sent_at
  end
end
