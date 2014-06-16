class ChangeInstagramIdTypeOfInstagramUsers < ActiveRecord::Migration
  def change
    change_column :instagram_users, :instagram_id, :string
  end
end