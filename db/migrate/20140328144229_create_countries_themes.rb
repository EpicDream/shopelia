class CreateCountriesThemes < ActiveRecord::Migration
  def change
    create_table :countries_themes, :force => true do |t|
      t.references :country
      t.references :theme
    end
  end
end