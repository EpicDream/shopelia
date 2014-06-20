class AddQualityRejectToLooks < ActiveRecord::Migration
  def change
    add_column :looks, :quality_rejected, :boolean, default:false
  end
end