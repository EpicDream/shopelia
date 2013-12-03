class CreateLooks < ActiveRecord::Migration
  def change
    create_table :looks do |t|
      t.string :uuid
      t.string :name
      t.string :url
      t.integer :flinker_id
      t.integer :post_id
      t.datetime :published_at

      t.timestamps
    end
  end
end
