class CreateAlgoliaTags < ActiveRecord::Migration
  def change
    create_table :algolia_tags do |t|
      t.string :name
      t.string :kind
      t.integer :count

      t.timestamps
    end
  end
end
