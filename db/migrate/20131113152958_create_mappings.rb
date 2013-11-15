class CreateMappings < ActiveRecord::Migration
  def change
    create_table :mappings do |t|
      t.text :mapping
      t.string :domain

      t.timestamps
    end
  end
end
