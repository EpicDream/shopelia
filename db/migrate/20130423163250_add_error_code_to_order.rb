class AddErrorCodeToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :error_code, :string
  end
end
