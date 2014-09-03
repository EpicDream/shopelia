class AddPrepublishedToLooks < ActiveRecord::Migration
  def change
    add_column :looks, :prepublished, :boolean, default:false
  end
end