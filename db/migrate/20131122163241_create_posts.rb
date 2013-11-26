class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.references :blog
      t.datetime :published_at
      t.string :link
      t.text :content
      t.text :description
      t.string :title
      t.string :author
      t.text :categories #temp : stocked as json
      t.text :images #temp : stocked as json
      t.text :products #temp : stocked as json
      t.timestamps
    end
  end
end
