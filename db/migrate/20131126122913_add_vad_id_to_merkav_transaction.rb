class AddVadIdToMerkavTransaction < ActiveRecord::Migration
  def change
    add_column :merkav_transactions, :vad_id, :integer
  end
end
