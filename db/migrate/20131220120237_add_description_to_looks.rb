class AddDescriptionToLooks < ActiveRecord::Migration
  def change
    add_column :looks, :description, :string
  end
end
