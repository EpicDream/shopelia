class AddDisplayOrderToFlinkers < ActiveRecord::Migration
  def change
    add_column :flinkers, :display_order, :integer
  end
end
