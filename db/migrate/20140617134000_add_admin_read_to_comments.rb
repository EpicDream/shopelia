class AddAdminReadToComments < ActiveRecord::Migration
  def change
    add_column :comments, :admin_read, :boolean, default:false
  end
end