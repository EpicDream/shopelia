class AddCountryIdToFlinkers < ActiveRecord::Migration
  def change
    add_column :flinkers, :country_id, :integer
  end
end
