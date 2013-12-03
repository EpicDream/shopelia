class AddDisplayOrderToImages < ActiveRecord::Migration
  def change
    add_column :images, :display_order, :integer
  end
end
