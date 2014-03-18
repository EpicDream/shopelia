class CreateThemes < ActiveRecord::Migration
  def change
    create_table :themes, :force => true do |t|
      t.integer :rank
      t.string :title
      t.timestamps
    end
  end
end