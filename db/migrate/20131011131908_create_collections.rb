class CreateCollections < ActiveRecord::Migration
  def change
    create_table :collections do |t|
      t.integer :user_id
      t.string :uuid
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
