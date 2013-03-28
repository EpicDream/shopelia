class CreatePsps < ActiveRecord::Migration
  def change
    create_table :psps do |t|
      t.string :name

      t.timestamps
    end
  end
end
