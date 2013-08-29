class CreateIncidents < ActiveRecord::Migration
  def change
    create_table :incidents do |t|
      t.integer :severity
      t.string :issue
      t.text :description
      t.boolean :processed, :default => false
      t.string :resource_type
      t.integer :resource_id

      t.timestamps
    end
  end
end
