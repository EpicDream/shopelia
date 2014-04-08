class AddSeasonToLooks < ActiveRecord::Migration
  def change
    add_column :looks, :season, :string
  end
end