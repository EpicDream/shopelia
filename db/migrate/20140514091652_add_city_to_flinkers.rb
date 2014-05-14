class AddCityToFlinkers < ActiveRecord::Migration
  def change
    add_column :flinkers, :city, :string
  end
end