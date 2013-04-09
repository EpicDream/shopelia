class AddAccessInfoToAddresses < ActiveRecord::Migration
  def change
    add_column :addresses, :access_info, :string
  end
end
