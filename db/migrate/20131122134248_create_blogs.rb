class CreateBlogs < ActiveRecord::Migration
  def change
    create_table :blogs do |t|
      t.string :url
      t.string :name
      t.timestamps
    end
  end
end
