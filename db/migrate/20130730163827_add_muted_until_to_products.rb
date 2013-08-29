class AddMutedUntilToProducts < ActiveRecord::Migration
  def change
    add_column :products, :muted_until, :datetime
  end
end
