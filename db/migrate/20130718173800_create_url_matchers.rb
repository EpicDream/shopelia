class CreateUrlMatchers < ActiveRecord::Migration
  def change
    create_table :url_matchers do |t|
      t.text :url
      t.text :canonical

      t.timestamps
    end
  end
end
