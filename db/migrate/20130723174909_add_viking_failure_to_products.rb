class AddVikingFailureToProducts < ActiveRecord::Migration
  def change
    add_column :products, :viking_failure, :boolean
  end
end
