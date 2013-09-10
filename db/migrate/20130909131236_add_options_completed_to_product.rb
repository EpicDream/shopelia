class AddOptionsCompletedToProduct < ActiveRecord::Migration
  def change
    add_column :products, :options_completed, :boolean, :default => false
  end
end
