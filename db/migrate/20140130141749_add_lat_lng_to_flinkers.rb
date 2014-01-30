class AddLatLngToFlinkers < ActiveRecord::Migration
  def change
    add_column :flinkers, :lat, :decimal
    add_column :flinkers, :lng, :decimal
  end
end