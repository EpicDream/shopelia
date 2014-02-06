class RepairSuckBowls < ActiveRecord::Migration
  def up
    add_column :flinker_authentications, :flinker_id_temp, :integer
    FlinkerAuthentication.all.each do |fa|
     fa.flinker_id_temp = fa.flinker_id.to_i
     fa.save!
    end
  end

  def down
    remove_column :flinker_authentications, :flinker_id_temp
  end
end