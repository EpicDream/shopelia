class AddMonetizableToEvents < ActiveRecord::Migration
  def change
    add_column :events, :monetizable, :boolean
  end
end
