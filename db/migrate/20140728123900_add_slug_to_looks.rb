class AddSlugToLooks < ActiveRecord::Migration
  def change
    add_column :looks, :slug, :string
    add_index :looks, :slug, unique: true
  end
end