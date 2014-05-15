class AddAreaToFlinkers < ActiveRecord::Migration
  def change
    add_column :flinkers, :area, :string
  end
end