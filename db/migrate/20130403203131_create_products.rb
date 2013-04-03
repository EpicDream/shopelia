class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.integer :merchant_id
      t.string :url
      t.string :image_url

      t.timestamps
    end
  end
end
