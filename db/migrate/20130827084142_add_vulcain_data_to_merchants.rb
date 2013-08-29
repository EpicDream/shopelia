class AddVulcainDataToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :vulcain_test_pass, :boolean
    add_column :merchants, :vulcain_test_output, :string
  end
end
