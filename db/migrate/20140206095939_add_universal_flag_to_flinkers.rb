class AddUniversalFlagToFlinkers < ActiveRecord::Migration
  def change
    add_column :flinkers, :universal, :boolean, default:false
  end
end