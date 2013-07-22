class AddVikingDataToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :viking_data, :text
  end
end
