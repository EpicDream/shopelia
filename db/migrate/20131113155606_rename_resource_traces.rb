class RenameResourceTraces < ActiveRecord::Migration
  def up
    rename_column :traces, :ressource, :resource
  end

  def down
    rename_column :traces, :resource, :ressources
  end
end
