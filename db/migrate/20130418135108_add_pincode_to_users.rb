class AddPincodeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :pincode, :string
  end
end
