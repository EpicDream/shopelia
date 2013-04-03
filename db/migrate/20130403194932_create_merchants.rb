class CreateMerchants < ActiveRecord::Migration
  def change
    create_table :merchants do |t|
      t.string :name
      t.string :logo
      t.string :url
      t.string :tc_url

      t.timestamps
    end
  end
end
