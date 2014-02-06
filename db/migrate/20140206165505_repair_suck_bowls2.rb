class RepairSuckBowls2 < ActiveRecord::Migration
  def up
    remove_column :flinker_authentications, :flinker_id
    rename_column :flinker_authentications, :flinker_id_temp, :flinker_id
  end

  def down
    rename_column :flinker_authentications, :flinker_id, :flinker_id_temp
    add_column :flinker_authentications, :flinker_id, :string
  end
end