class AddFlinkerIdToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :flinker_id, :integer
    add_column :devices, :is_beta, :boolean
  end
end
