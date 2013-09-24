class AddUniqueUrlIndexOnProducts < ActiveRecord::Migration
  def change
    add_index :products, :url, :unique => true
  end
end
