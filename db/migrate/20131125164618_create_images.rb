class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :url
      t.string :type #STI
      t.timestamps
    end
  end
end
