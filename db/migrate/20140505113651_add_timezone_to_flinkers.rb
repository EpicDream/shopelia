class AddTimezoneToFlinkers < ActiveRecord::Migration
  def change
    add_column :flinkers, :timezone, :string
  end
end