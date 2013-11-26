class CreateFlinkers < ActiveRecord::Migration
  def change
    create_table :flinkers do |t|
      t.string :name
      t.string :url
      t.attachment :avatar

      t.timestamps
    end
  end
end
