class AddUuidToLookProducts < ActiveRecord::Migration
  def change
    add_column :look_products, :uuid, :string
  end
end