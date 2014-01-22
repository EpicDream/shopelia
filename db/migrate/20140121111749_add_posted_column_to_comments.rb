class AddPostedColumnToComments < ActiveRecord::Migration
  def change
    add_column :comments, :posted, :boolean, default:false
  end
end