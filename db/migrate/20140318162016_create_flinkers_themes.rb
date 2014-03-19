class CreateFlinkersThemes < ActiveRecord::Migration
  def change
    create_table :flinkers_themes, :force => true do |t|
      t.references :flinker
      t.references :theme
    end
  end
end