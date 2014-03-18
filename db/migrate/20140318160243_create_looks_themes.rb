class CreateLooksThemes < ActiveRecord::Migration
  def change
    create_table :looks_themes, :force => true do |t|
      t.references :look
      t.references :theme
    end
  end
end